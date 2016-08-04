Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class EditWell
  Inherits System.Web.UI.Page

  Protected Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click

    Try
      Dim wa As WellActionDTO = CType(Session("WellActionDTO"), WellActionDTO)

      Master.CheckForUpdates(wa)

      If Not wa.IsWellVersionChanged And Not wa.IsWellLicenseChanged And Not wa.IsWellNodeVersionChanged Then
        Dim srMsg As String = "No changes made to this well version. Save to database not done."
        Dim myscript As String = "window.onload = function() {alert('" + srMsg + "');}"
        Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
        Exit Sub
      End If

      Master.GetwaUpdates(wa)

      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)

      wa = gw.ProcessWellAction(wa)

      If wa.STATUS_CD = WELL_ACTION_COMPLETE Then

        Master.ClearPageSessionVars()
        Page.Response.Redirect("~/WellVersion.aspx?Wellkey=" & Server.HtmlEncode(wa.UWI & "," & wa.SOURCE) & "&Mode=E")

      Else

        Master.ResetControls()
        Master.HandleErrors(wa)

        Session("WellActionDTO") = New WellActionDTO(gw.GetVersionOrigUOM(wa.UWI, wa.SOURCE))

      End If

      'Catch ex As Exception
      'Throw ex
    Finally

    End Try

  End Sub

  Protected Sub btnCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCancel.Click

    Master.ClearPageSessionVars()
    Page.Response.Redirect("~/Default.aspx")

  End Sub

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    If Not Page.IsPostBack And Not Master.ControlCausedCallback Then

      Master.Permission = USER_UPDATE_PERMISSION
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
      CType(Master.FindControl("ddlSource"), ComboBox).Enabled = False

      Master.AddControlAttributes()

    End If

  End Sub

#Region "Private Functions"


#End Region

End Class