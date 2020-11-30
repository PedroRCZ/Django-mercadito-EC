
# ------------------
# Crear encio de email\
# ------------------
# Librerias de Api\

from __future__ import print_function
from sib_api_v3_sdk.rest import ApiException
from pprint import pprint
import time
import sib_api_v3_sdk
from datetime import date
from datetime import datetime

class email_metodos:

    def __init__(self):
        pprint
        
    def envio_email(self,correo,nombre,apellido,total,productos):

    
        configuration = sib_api_v3_sdk.Configuration()
        configuration.api_key['api-key'] = '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'
        fecha = datetime.now()
        dia = fecha.day
        mes = fecha.month
        anio = fecha.year
        fecha_compra =str(dia)+"/"+str(mes)+"/"+str(anio)
        # cra un instancia de la Api
        
        api_instance = sib_api_v3_sdk.TransactionalEmailsApi(sib_api_v3_sdk.ApiClient(configuration))
        send_smtp_email = sib_api_v3_sdk.SendSmtpEmail(to=[{"email":correo,"name":nombre}], template_id=2, params={ "DATE": fecha_compra,"NOMBRE":nombre,"APELLIDO":apellido,"TOTAL":total,"PRODUCTOS":productos})

        try:
            # Envio de email transaccional
            api_response = api_instance.send_transac_email(send_smtp_email)
            pprint(api_response)
        except ApiException as e:
            print("Error al envio: %s\n" % e)
        




