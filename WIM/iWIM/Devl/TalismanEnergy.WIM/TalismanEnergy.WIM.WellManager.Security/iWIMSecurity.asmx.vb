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

        AuthenticateWebMethod(iWIMAuth)

        Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
        Dim gw As New TalismanEnergy.WIM.GatewayProxy.GatewayAccess(dbconnection)

        Return IIf(gw.ValidateUser(iUserIdentity), True, False)

    End Function

    Private Sub AuthenticateWebMethod(ByVal soapAuthHeader As AuthHeader)

        If soapAuthHeader Is Nothing Then
            Dim exp As New Exception("An authentication http header must be supplied to call this method.")
            Throw exp
        Else
            Dim service As New WSMTAuthService.AuthService
            If Not service.CanExecuteByName(soapAuthHeader.ApplicationName, _
                                            soapAuthHeader.ApplicationVersion, _
                                            ConfigurationManager.AppSettings("WSMTAuth_AppName").ToString(), _
                                            ConfigurationManager.AppSettings("WSMTAuth_Version").ToString(), _
                                            "IsValidUser", _
                                            soapAuthHeader.Password, _
                                            soapAuthHeader.UserName) Then
                Dim exp As New Exception("The application is not allowed to call this method, please contact your WSMT administrator.")
                Throw exp
            End If
        End If

    End Sub

End Class