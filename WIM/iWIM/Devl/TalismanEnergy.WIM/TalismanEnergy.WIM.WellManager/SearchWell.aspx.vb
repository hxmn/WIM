Imports TalismanEnergy.WIM.GatewayProxy

Partial Public Class SearchWell
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then
            Response.Redirect(ConfigurationManager.AppSettings("DataFinderURL").ToString)
        End If

    End Sub

End Class