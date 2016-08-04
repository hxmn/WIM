Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.ComponentModel

<System.Web.Services.WebService(Namespace:="http://tempuri.org/WIM/iWIMSecurity")> _
<System.Web.Services.WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<ToolboxItem(False)> _
Public Class iWIMSecurity
  Inherits System.Web.Services.WebService

  Public iWIMAuth As AuthHeader

  <WebMethod(), SoapHeader("iWIMAuth")> _
      Public Function IsValidUser(ByVal iUserIdentity As String) As Boolean

    ' checking if the request is permitted was removed for version 1.1
    ' (too many timeouts)
    ''AuthenticateWebMethod(iWIMAuth)

    Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
    Dim gw As New TalismanEnergy.WIM.GatewayProxy.GatewayAccess(dbconnection)

    Dim valid As Boolean = gw.ValidateUser(iUserIdentity)

    Dim sMsg As String = String.Format("Validating user ""{1}"".{0}Result: {2}.", _
                                        vbCrLf, _
                                        iUserIdentity, _
                                        valid)

    WriteToEventLog(sMsg, EventLogEntryType.Information)

    Return valid

  End Function

  <WebMethod()> _
  Public Function Version() As String
    Return ConfigurationManager.AppSettings("SVC_NAME") + " " + ConfigurationManager.AppSettings("SVC_VERSION")
  End Function

  <WebMethod()> _
  Public Function DataSource() As String
    Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
    Dim gw As New TalismanEnergy.WIM.GatewayProxy.GatewayAccess(dbconnection)
    Dim dbName As String = gw.GetDBName()
    Return dbName
  End Function

  'Private Sub AuthenticateWebMethod(ByVal soapAuthHeader As AuthHeader)

  '  If soapAuthHeader Is Nothing Then
  '    Dim exp As New Exception("An authentication http header must be supplied to call this method.")
  '    Throw exp
  '  Else
  '    Dim service As New WSMTAuthService.AuthService
  '    If Not service.CanExecuteByName(soapAuthHeader.ApplicationName, _
  '                                    soapAuthHeader.ApplicationVersion, _
  '                                    ConfigurationManager.AppSettings("WSMTAuth_AppName").ToString(), _
  '                                    ConfigurationManager.AppSettings("WSMTAuth_Version").ToString(), _
  '                                    "IsValidUser", _
  '                                    soapAuthHeader.Password, _
  '                                    soapAuthHeader.UserName) Then
  '      Dim exp As New Exception("The application is not allowed to call this method, please contact your WSMT administrator.")
  '      Throw exp
  '    End If
  '  End If

  'End Sub

  Const EVENT_LOG_NAME As String = "WIM.iWIMSecurity"

  Sub WriteToEventLog(ByVal Message As String, ByVal Type As EventLogEntryType)

    Dim Log As EventLog = New EventLog
    Log.Source = EVENT_LOG_NAME
    Log.WriteEntry(Message, Type)

  End Sub

End Class