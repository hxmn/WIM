Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class ViewWell
  Inherits System.Web.UI.Page

  Protected Sub btnDone_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDone.Click

    Master.ClearPageSessionVars()
    Page.Response.Redirect("~/Default.aspx")

  End Sub

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    Master.Permission = String.Empty
    If Not Page.IsPostBack And Not Master.ControlCausedCallback Then

      Master.ClearPageSessionVars()
      Master.InitializeLookUpListControls()

      Dim WellInfo() As String = Server.HtmlDecode(Request.QueryString("Wellkey")).Split(",")
      Dim TLMId As String = WellInfo(0)
      Dim Source As String = WellInfo(1)
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As New WellActionDTO(gw.GetVersionOrigUOM(TLMId, Source))
      Session("WellActionDTO") = wa

      Master.SetControlValues(wa, True)
      Master.SetReadOnly()
    End If

  End Sub

#Region "Private Functions"


#End Region

End Class