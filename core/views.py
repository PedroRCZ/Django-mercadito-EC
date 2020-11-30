from django.conf import settings
from django.contrib import messages
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.shortcuts import render, get_object_or_404  # para buscar en la base de datos
from django.views.generic import ListView, DetailView, View
from django.shortcuts import redirect
from django.utils import timezone
from .forms import CheckoutForm, CouponForm, RefundForm
from .models import Item, OrderItem, Order, BillingAddress, Payment, Coupon, Refund, Category,Usuarios
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response
from django.core.mail import send_mail
from django.conf import settings
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from pprint import pprint


import random
import string
import stripe
stripe.api_key = settings.STRIPE_SECRET_KEY


from .configuracion_email import email_metodos


##Variables globales
correocliente = ""
correo = ""

def create_ref_code():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=20))


class PaymentView(View):
    def get(self, *args, **kwargs):
        # order
        order = Order.objects.get(user=self.request.user, ordered=False)
        if order.billing_address:
            context = {
                'order': order,
                'DISPLAY_COUPON_FORM': False
            }
            return render(self.request, "payment.html", context)
        else:
            messages.warning(
                self.request, "no ha agregado una dirección de facturación")
            return redirect("core:checkout")

    def post(self, *args, **kwargs):
        order = Order.objects.get(user=self.request.user, ordered=False)
        token = self.request.POST.get('stripeToken')
        amount = int(order.get_total() * 100)

        context = {
            'object': order
        }
        try:
            charge = stripe.Charge.create(
                amount=amount,  # a dolares
                currency="usd",
                source=token
            )
            # crea los pagos
            payment = Payment()
            payment.stripe_charge_id = charge['id']
            payment.user = self.request.user
            payment.amount = order.get_total()
            payment.save()

            #hace el pago con la orden
            order.ordered = True
            order.payment = payment
            # TODO : referencia de codigo
            order.ref_code = create_ref_code()
            order.save()

            ## Enviar email a cliente 
        
            usuario = order.__str__   # me obtiene el nombre de usuario
        
            correo = order.get_email()
        
            nombre = order.get_nombre()
            if len(nombre) == 0:
                nombre = order.get_usuario()        

            apellido = order.get_apellido()
            if len(apellido) == 0:
                apellido = ""
            total = order.get_total()
            productos = order.get_productos_seleccionados()
                    
            programa = email_metodos()
            programa.envio_email(correo,nombre,apellido,"$"+str(total),productos)

            messages.success(self.request, "La orden fue enviada exitosamente")
            return redirect("/")
        
        except stripe.error.CardError as e:
            # Since it's a decline, stripe.error.CardError will be caught
            body = e.json_body
            err = body.get('error', {})
            messages.error(self.request, f"{err.get('message')}")
            return redirect("/")

        except stripe.error.RateLimitError as e:
            # Too many requests made to the API too quickly
            messages.error(self.request, "RateLimitError")
            return redirect("/")

        except stripe.error.InvalidRequestError as e:
            messages.error(self.request, "parámetros inválidos")
            return redirect("/")

        except stripe.error.AuthenticationError as e:
            messages.error(self.request, "Sin autenticación")
            return redirect("/")

        except stripe.error.APIConnectionError as e:
            messages.error(self.request, "Error de red")
            return redirect("/")

        except stripe.error.StripeError as e:
            messages.error(self.request, "Algo salió mal")
            return redirect("/")

        except Exception as e:
            messages.error(self.request, "Se produjo un error grave")
            return redirect("/")

        
    
class HomeView(ListView):
    template_name = "index.html"
    queryset = Item.objects.filter(is_active=True)
    context_object_name = 'items'


class OrderSummaryView(LoginRequiredMixin, View):
    def get(self, *args, **kwargs):
        try:
            order = Order.objects.get(user=self.request.user, ordered=False)
            context = {
                'object': order
            }
            return render(self.request, 'order_summary.html', context)
        except ObjectDoesNotExist:
            messages.error(self.request, "USTED NO TIENE NINGUNA ORDEN ACTIVA")
            return redirect("/")


class ShopView(ListView):
    model = Item
    paginate_by = 6
    template_name = "shop.html"


class ItemDetailView(DetailView):
    model = Item
    template_name = "product-detail.html"

class quienesSomos(DetailView):
    model = Category
    template_name = "quienesSomos.html"

# class CategoryView(DetailView):
#     model = Category
#     template_name = "category.html"

class CategoryView(View):
    def get(self, *args, **kwargs):
        category = Category.objects.get(slug=self.kwargs['slug'])
        item = Item.objects.filter(category=category, is_active=True)
        context = {
            'object_list': item,
            'category_title': category,
            'category_description': category.description,
            'category_image': category.image
        }
        return render(self.request, "category.html", context)

class envioCorreo(View):
    def get(self, *args, **kwargs):
        try:
            order = Order.objects.get(user=self.request.user, ordered=False)
            form = CheckoutForm()
            context = {
                'form': form,
                'couponform': CouponForm(),
                'order': order,
                'DISPLAY_COUPON_FORM': True
            }
            return render(self.request, "form_correo.html", context)

        except ObjectDoesNotExist:
            messages.info(self.request, "No tienes un pedido activo")
            return redirect("core:checkout")

class confirmacion(View):
    def get(self, *args, **kwargs):
        try:
            order = Order.objects.get(user=self.request.user, ordered=False)
            form = CheckoutForm()
            context = {
                'form': form,
                'couponform': CouponForm(),
                'order': order,
                'DISPLAY_COUPON_FORM': True
            }
            return render(self.request, "informacionpago.html", context)


        except ObjectDoesNotExist:
            messages.info(self.request, "No tienes un pedido activo")
            return redirect("core:checkout")
               
 # Metodo para la orden procesado al correo del usuario vendedor        
def process_order(request):
    order = Order.objects.create(user=request.user, completed=True)
    cart = cart(request)
    order_lines = list()
    for key, value in cart.cart.items():
        order_lines.append(
            OrderLine(
                product_id=key,
                quantity=value["quantity"],
                user=request.user,
                order=order
            )
        )

    OrderLine.objects.bulk_create(order_lines)

    send_order_email(
        order=order,
        order_lines=order_lines,
        username=request.user.username,
        user_email=request.user.email
    )

    cart.clear()

    messages.success(request, "El pedido se ha creado correctamente!")
    return redirect("/")


# Método para enviarle informacion del cliente de lo que compró

def send_order_email(**kwargs):
    subject = "Gracias por tu pedido"
    html_message = render_to_string("nuevo_pedido.html", {
        "order": kwargs.get("order"),
        "order_lines": kwargs.get("order_lines"),
        "username": kwargs.get("username")
    })
    plain_message = strip_tags(html_message)
    from_email = settings.EMAIL_HOST_USER
  #  to = kwargs.get("account_email")
    correcliente = ""
    #send_mail(subject, plain_message, from_email, [to], html_message=html_message)
    recipient_list=[correocliente]
    send_mail(subject,plain_messag,email_from,recipient_list,html_message=html_message)




# Clase de Formulario ed pag
class CheckoutView(View):
    def get(self, *args, **kwargs):
        try:
            order = Order.objects.get(user=self.request.user, ordered=False)
            form = CheckoutForm()
            context = {
                'form': form,
                'couponform': CouponForm(),
                'order': order,
                'DISPLAY_COUPON_FORM': True
            }
            return render(self.request, "checkout.html", context)

        except ObjectDoesNotExist:
            messages.info(self.request, "No tienes un pedido activo")
            return redirect("core:checkout")

    def post(self, *args, **kwargs):
        form = CheckoutForm(self.request.POST or None)
        try:
            order = Order.objects.get(user=self.request.user, ordered=False)
            print(self.request.POST)
            if form.is_valid():
                street_address = form.cleaned_data.get('street_address')
                correo = form.cleaned_data.get('correo')
                apartment_address = form.cleaned_data.get('apartment_address')
                country = form.cleaned_data.get('country')
                zip = form.cleaned_data.get('zip')  # codig postal
                # add functionality for these fields
                # same_shipping_address = form.cleaned_data.get(
                #     'same_shipping_address')
                # save_info = form.cleaned_data.get('save_info')
                payment_option = form.cleaned_data.get('payment_option')
                billing_address = BillingAddress(
                    user=self.request.user,
                    street_address=street_address,
                    apartment_address=apartment_address,
                    country=country,
                    zip=zip,
                    address_type='B'
                )
                billing_address.save()
                order.billing_address = billing_address
                order.save()

                # El pago es por depósito bancario
                # if payment_option == 'S':
            
                #     return redirect('core:payment', payment_option='Deposito Bancario')
                
                #  # El pago es por tarjeta
                # elif payment_option == 'P':

                    
                return redirect('core:payment', payment_option='paypal')
                # else:
                #     messages.warning(
                #         self.request, "Seleccione una opción de pago no válida")
                #     return redirect('core:checkout')
        except ObjectDoesNotExist:
            messages.error(self.request, "No tienes un pedido activo")
            return redirect("core:order-summary")


# def home(request):
#     context = {
#         'items': Item.objects.all()
#     }
#     return render(request, "index.html", context)
#
#
# def products(request):
#     context = {
#         'items': Item.objects.all()
#     }
#     return render(request, "product-detail.html", context)
#
#
# def shop(request):
#     context = {
#         'items': Item.objects.all()
#     }
#     return render(request, "shop.html", context)


@login_required
def add_to_cart(request, slug):
    item = get_object_or_404(Item, slug=slug)
    order_item, created = OrderItem.objects.get_or_create(
        item=item,
        user=request.user,
        ordered=False
    )
    order_qs = Order.objects.filter(user=request.user, ordered=False)
    
    if order_qs.exists():
        order = order_qs[0]
        if order.items.filter(item__slug=item.slug).exists():
            order_item.quantity += 1
            order_item.save()
            messages.info(request, "Se actualizó la cantidad del Articulo.")
            return redirect("core:order-summary")
        else:
            order.items.add(order_item)
            messages.info(request, "El artículo fue agregado a su carrito.")
            return redirect("core:order-summary")
    else:
        ordered_date = timezone.now()
        order = Order.objects.create(
            user=request.user, ordered_date=ordered_date)
        order.items.add(order_item)
        messages.info(request, "El artículo fue agregado a su carrito.")
    return redirect("core:order-summary")

# Remover producto de carrito
@login_required
def remove_from_cart(request, slug):
    item = get_object_or_404(Item, slug=slug)
    order_qs = Order.objects.filter(
        user=request.user,
        ordered=False)
    if order_qs.exists():
        order = order_qs[0]
        # check if the order item is in the order
        if order.items.filter(item__slug=item.slug).exists():
            order_item = OrderItem.objects.filter(
                item=item,
                user=request.user,
                ordered=False
            )[0]
            order.items.remove(order_item)
            messages.info(request, "Item was removed from your cart.")
            return redirect("core:order-summary")
        else:
            # add a message saying the user dosent have an order
            messages.info(request, "Item was not in your cart.")
            return redirect("core:product", slug=slug)
    else:
        # add a message saying the user dosent have an order
        messages.info(request, "u don't have an active order.")
        return redirect("core:product", slug=slug)
    return redirect("core:product", slug=slug)


@login_required
def remove_single_item_from_cart(request, slug):
    item = get_object_or_404(Item, slug=slug)
    order_qs = Order.objects.filter(
        user=request.user,
        ordered=False)
    if order_qs.exists():
        order = order_qs[0]
        # check if the order item is in the order
        if order.items.filter(item__slug=item.slug).exists():
            order_item = OrderItem.objects.filter(
                item=item,
                user=request.user,
                ordered=False
            )[0]
            if order_item.quantity > 1:
                order_item.quantity -= 1
                order_item.save()
            else:
                order.items.remove(order_item)
            messages.info(request, "La cantidad de este artículo se actualizó.")
            return redirect("core:order-summary")
        else:
            # add a message saying the user dosent have an order
            messages.info(request, "El artículo no estaba en tu carrito.")
            return redirect("core:product", slug=slug)
    else:
        # add a message saying the user dosent have an order
        messages.info(request, "no tienes una orden activa.")
        return redirect("core:product", slug=slug)
    return redirect("core:product", slug=slug)


def get_coupon(request, code):
    try:
        coupon = Coupon.objects.get(code=code)
        return coupon
    except ObjectDoesNotExist:
        messages.info(request, "Este cupón no existe")
        return redirect("core:checkout")


class AddCouponView(View):
    def post(self, *args, **kwargs):
        form = CouponForm(self.request.POST or None)
        if form.is_valid():
            try:
                code = form.cleaned_data.get('code')
                order = Order.objects.get(
                    user=self.request.user, ordered=False)
                order.coupon = get_coupon(self.request, code)
                order.save()
                messages.success(self.request, "Cupón agregado exitosamente")
                return redirect("core:checkout")

            except ObjectDoesNotExist:
                messages.info(request, "No tienes un pedido activo")
                return redirect("core:checkout")


class RequestRefundView(View):
    def get(self, *args, **kwargs):
        form = RefundForm()
        context = {
            'form': form
        }
        return render(self.request, "request_refund.html", context)

    def post(self, *args, **kwargs):
        form = RefundForm(self.request.POST)
        if form.is_valid():
            ref_code = form.cleaned_data.get('ref_code')
            message = form.cleaned_data.get('message')
            email = form.cleaned_data.get('email')
            # edit the order
            try:
                order = Order.objects.get(ref_code=ref_code)
                order.refund_requested = True
                order.save()

                # store the refund
                refund = Refund()
                refund.order = order
                refund.reason = message
                refund.email = email
                refund.save()

                messages.info(self.request, "Your request was received")
                return redirect("core:request-refund")

            except ObjectDoesNotExist:
                messages.info(self.request, "This order does not exist")
                return redirect("core:request-refund")
     
  