import logging
import json
import datetime
import re
import copy
import urllib.parse

from dateutil.relativedelta import relativedelta
from datetime import datetime, timedelta
from thehive4py.api import TheHiveApi
from thehive4py.auth import BearerAuth
from thehive4py.models import Case, CaseTask, CaseTaskLog, CaseObservable, AlertArtifact, Alert, CustomFieldHelper, Version
from thehive4py.query import Eq, Between, And, Gt, In, Not, ContainsString, Like


# Disable insecure warnings
requests.packages.urllib3.disable_warnings()


class Client(BaseClient):

    def __init__(self, cert=True, url=None, api_key=None):
        ## Connecting to TheHiveAPI
        self.theHiveApi = TheHiveApi(url,api_key,version=Version.THEHIVE_4.value,cert=cert)
        self.auth = BearerAuth(api_key)
        self.url = url

    ### ALERTS

    def get_alert(self, alert_id):
        response = self.theHiveApi.get_alert(alert_id)
        if response.status_code == 200: # respuesta de estado satisfactorio HTTP 200 OK indica que la solicitud ha tenido éxito.
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Get Alert failed')

    def get_alert_object(self, alert_id):
        response = self.theHiveApi.get_alert(alert_id)
        if response.status_code == 200:
            data = response.json()
            alert = Alert(json=data)
            return alert
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Get Alert failed')

    def create_alert(self, alert):
        response = self.theHiveApi.create_alert(alert)
        if response.status_code == 201:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Alert creation failed')

    def update_alert(self, alertId, alert, fields=[]):
        response = self.theHiveApi.update_alert(alertId, alert, fields)
        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('update alert failed')

    def mark_alert_as_read(self, alert_id):
        response = self.theHiveApi.mark_alert_as_read(alert_id)
        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('mark alert as read failed')

    def promote_alert_to_case(self, alert_id, case_template=None):
        response = self.theHiveApi.promote_alert_to_case(alert_id, case_template)
        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Promote alert to case failed')

    def find_alerts(self, q, sort=[], range='all'):
        """
            Search for alerts in TheHive for a given query
            :param q: TheHive query
            :type q: dict
            :return results: list of dict, each dict describes an alert
            :rtype results: list
        """
        response = self.theHiveApi.find_alerts(query=q, sort=sort, range=range)
        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Find alerts failed')

    def merge_alert_into_case(self, alert_id, case_id):
        response = self.theHiveApi.merge_alert_into_case(alert_id, case_id)
        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Merge alert into case failed')

    def create_alert_artifact(self, alert_id, alert_artifact):
        response = self.theHiveApi.create_alert_artifact(alert_id, alert_artifact)
        if response.status_code == 201:
            return response.json()
        else:
            return_error(response.json())
            demisto.error('Create alert artifact failed')

    ### CASES
    def get_case(self, case_id):
        case = self.theHiveApi.case(case_id)
        return case

    def find_cases(self, q, sort=[], range='all'):
        """
            Search for cases in TheHive for a given query
            :param q: TheHive query
            :type q: dict
            :return results: list of dict, each dict describes an alert
            :rtype results: list
        """
        response = self.theHiveApi.find_cases(query=q, sort=sort, range=range)

        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Find cases failed')

    def create_case(self, case):
        response = self.theHiveApi.create_case(case)

        if response.status_code == 201:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Case creation failed')

    def update_case(self, case, fields=[]):
        response = self.theHiveApi.update_case(case, fields=[])

        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Case update failed')

    ### TASKS
    def create_task(self, case_id, task):
        response = self.theHiveApi.create_case_task(case_id, task)

        if response.status_code == 201:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Task creation failed')

    def get_case_tasks(self, case_id):
        response = self.theHiveApi.get_case_tasks(case_id)

        if response.status_code == 200:
            return response.json()
        else:
            return_error('Status code: ' + str(response.status_code) + ' | Error: ' + str(response.json()))
            demisto.error('Get case tasks failed')



''' COMMAND FUNCTIONS '''
def get_new_alerts(client: Client, args:dict):
    query = And(Eq('status', 'New'))

    alerts = client.find_alerts(query)
    res = CommandResults(
        outputs_prefix='Alert',
        #outputs_key_field='SourceRef',
        outputs=alerts
    )
    return_results(res)

## CASES
def get_cases_by_Client_command(client: Client, args:dict):
    clientName = str(args.get('client',None))
    casosaexcluir = [14010, 14210, 14212, 14188, 14245, 14314, 14363, 14977, 14966, 15242, 15241, 15003, 14985, 14009, 15555, 15779 ]
    query = Eq('customFields.cliente.string', clientName)
    cases = client.find_cases(q=query)
    result = []
    md = ""
    for case in cases:
        try:
            if int(case["caseId"]) >= 12536 and case['customFields']['tipoDeCaso']['string'] != "Requerimiento del cliente" and int(case["caseId"]) not in casosaexcluir :
                #print("Buscando id")
                idcaso = case['_id']
                #print("Buscando title")
                title = case['title']
                ### Buscamos el sumario del caso. A veces existe a veces no
                try:
                    case_summary = case['summary']
                except:
                    case_summary = ""
                #print("Buscando startdate")
                start_date = int(case['startDate'])/1000
                #print("Modificando Startdate to case_start")
                case_start = datetime.utcfromtimestamp(start_date).strftime('%d/%m/%Y %H:%M')
                #print("Buscando created by")
                case_created_by = case['createdBy']
                #print("Buscando caseid")
                case_id = case['caseId']
                #print("Buscando usecase")
                case_usecase = case['customFields']['casoDeUso']['string']

                case_type = "Alert" if case['customFields']['tipoDeCaso']['string'] == "Incidente" else ""
                #print("Buscando site")
                case_site = case['customFields']['Site']['string']
                #print("Buscando country")
                case_country = case['customFields']['Country']['string']
                #print("Buscando network")
                case_network = case['customFields']['iOCNetwork']['string']

                ### Tratamos de encontrar la fecha de cierre. Si la encontramos entonces el caso esta cerrado y ademas tenemos fecha de cierre. Sino, todavia no conocemos el estado del caso
                try:
                    case_close = int(case['endDate'])/1000
                    case_close = datetime.utcfromtimestamp(case_close).strftime('%d/%m/%Y %H:%M')
                    case_state = "Closed"
                except:
                    case_close = ""
                    case_state = " "
                #print("Buscando IOC origen")
                case_ips = case['customFields']['iOCOrigen']['string']

                ### Verificamos si el caso fue enviado. Si lo fue, obtenemos la fecha, sino, sabemos que el caso no fue enviado.
                try:
                    case_sent = case['customFields']['communicationDate']['date']
                    if case_sent == "":

                        case_sent = "Case not send yet"
                    else:
                        case_sent = case_sent/1000
                        #case_sent = datetime.fromtimestamp(case_sent)
                        case_sent = datetime.utcfromtimestamp(case_sent).strftime('%d/%m/%Y %H:%M')
                except:
                    case_sent = "Case not send yet"

                case_description = case['title']
                ### Terminamos de definir el estado del caso. Si esta cerrado = cerrado y sacamos la descripcion del caso con la razon de cierre. Si no esta cerrado, pero esta enviado, = On treatment. Si no esta cerrado ni tampoco enviado, = investigacion
                if case_state == "Closed":
                    case_state = "Closed"
                elif case_state != "Closed" and case_sent != "Case not send yet":
                    case_state = "On treatment"
                else:
                    case_state = "Investigation"
                if case_state == "Closed":
                    case_state_description = case_summary
                else:
                    case_state_description = case['customFields']['ticketDescripcionDelEstado']['string']


                result.append({'theHiveID': idcaso, 'CaseID':case_id,'CaseUseCase': case_usecase,'Site': case_site, 'Network': case_network,
                'Title':title, 'CaseStart':case_start, 'CaseCreatedBy': case_created_by, 'CaseIps': case_ips, 'CaseSent': case_sent,
                    'StateDescription': case_state_description, 'CaseClose': case_close
                })
        except:
            print("Please check if case: {} has all the required information in details tab and run the script again.".format(case["caseId"]))

    res = CommandResults(
        outputs_prefix='Case',
        outputs_key_field='CaseID',
        outputs=result
    )
    return_results(res)

def get_start_and_close_dates(client: Client, args:dict):
    theHiveID = str(args.get('theHiveID',None))
    THEHIVE_URL = 'http://thehive.base4sec.local:9000'
    THEHIVE_API_KEY = 'LMENLv3oarRjSJS/k+X661KZsXHxjABk'
    API = TheHiveApi(THEHIVE_URL, THEHIVE_API_KEY)

    md = ""
    results = []
    headers = {"Authorization": "Bearer {}".format(THEHIVE_API_KEY), "Content-Type": "application/json", "Accept": "application/json"}
    THEHIVE_URL2 = 'https://thehive.base4sec.local/api/v1/query?'
    queryz = {"query":[{"_name":"getCase","idOrName":""+ str(theHiveID) +""},{"_name":"alerts"}]}
    data = json.dumps(queryz).encode("utf-8")
    url = THEHIVE_URL2
    alerts = requests.post(url, data=data, headers=headers, verify= False)
    alerts = alerts.json()
    lastAlert = 0
    cantidadAlertas = len(alerts)
    if cantidadAlertas >= 1:
        for alert in alerts:
            if alert['_createdAt']> lastAlert:
                lastAlert = alert['_createdAt']
        results.append({'LastAlert': lastAlert, 'cantidadAlertas': cantidadAlertas})
    else:
        lastAlert = "Unkwown"
        results.append({'LastAlert': lastAlert, 'cantidadAlertas': cantidadAlertas})

    md += tableToMarkdown('TerniumAlerts', results, headers=['theHiveID','LastAlert','cantidadAlertas'])

    res = CommandResults(
        outputs_prefix='Case',
        outputs_key_field='CaseID',
        readable_output=results,
        outputs=results
    )
    return_results(res)

def test_command(client: Client, args:dict):

    var1 = args.get('var1',None)
    var2 = args.get('var2',None)

    suma = int(var1) + int(var2)

    resultado = {
        'suma':suma,
        'extra': "abcdefg",
        'test':{'a':2,'b':3}
    }

    res = CommandResults(
        outputs_prefix='output',
        outputs=resultado
    )
    return_results(res)


def calculate_Dates(client: Client, args:dict):
    cases = str(args.get('Case',None))
    for case in cases:
        print(case)

        #comienzo = cases[i]['CaseStart']
        #envio = cases[i]['CaseSent']
        #cierre = cases[i]['CaseClose']
        #estado = cases[i]['CaseState']
        #print (comienzo)
        #if envio != "Case not send yet" and estado == "Closed":
            #start = datetime.strptime(envio, '%d/%m/%Y %H:%M')
            #close = datetime.strptime(cierre, '%d/%m/%Y %H:%M')
            #diff = relativedelta(close, start)
            #dias = str(diff.days)
            #horas = str(diff.hours)
            #minutos = str(diff.minutes)
            #closed_time = dias + "D, " + horas + "h, " + minutos + "m"
        #elif envio == "Case not send yet" and estado == "Closed":
            #start = datetime.strptime(comienzo, '%d/%m/%Y %H:%M')
            #close = datetime.strptime(cierre, '%d/%m/%Y %H:%M')
            #diff = relativedelta(close, start)
            #dias = str(diff.days)
            #horas = str(diff.hours)
            #minutos = str(diff.minutes)
            #closed_time = dias + "D, " + horas + "h, " + minutos + "m"
        #else:
            #closed_time = "Open"

        #closed_time = {"ClosedTime":closed_time}
        #cases[i].update(closed_time)


    res = CommandResults(
        outputs_prefix='Case',
        outputs_key_field='CaseID',
        readable_output=cases,
        outputs=cases
    )
    return_results(res)

### MAIN

def main() -> None:
    params = demisto.params()
    args = demisto.args()
    api_key = params['apiKey']
    url = params.get('url')
    cert_verify = not demisto.params().get('insecure', True)

    command = demisto.command()

    command_map = {
        'thehive-get-cases-by-Client': get_cases_by_Client_command,
        'thehive-get-start-and-close-dates': get_start_and_close_dates,
        'thehive-calculate-Dates': calculate_Dates,
        'test-command': test_command,
        'thehive-get-new-alerts':get_new_alerts
    }
    demisto.debug(f'Command being called is {command}')
    try:
        client = Client(
            url=url,
            api_key=api_key,
            cert=cert_verify
        )

        if command == 'test-module':
            # This is the call made when pressing the integration Test button.
            result = test_module(client, args)
            return_results(result)

        elif command in command_map:
            command_map[command](client, args)  # type: ignore

    except Exception as err:
        demisto.error(traceback.format_exc())  # print the traceback
        return_error(f'Failed to execute {command} command. \nError: {str(err)}')


if __name__ in ('__main__', '__builtin__', 'builtins'):
    main()