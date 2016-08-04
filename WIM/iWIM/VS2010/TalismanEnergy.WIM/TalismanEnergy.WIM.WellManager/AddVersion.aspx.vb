Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class AddVersion
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    Master.Permission = USER_ADD_PERMISSION
    If Not Page.IsPostBack And Not Master.ControlCausedCallback Then

      Master.ClearPageSessionVars()
      Master.InitializeLookUpListControls()

      Dim WellInfoStr = Request.QueryString("Wellkey")
      ' what will happend if Request.QueryString("Wellkey") is NULL?
      If Request.QueryString("Wellkey") Is Nothing Then
        WellInfoStr = "you are in trouble"
      End If
      Dim WellInfo() As String = Server.HtmlDecode(Request.QueryString("Wellkey")).Split(",")
      Dim TLMId As String = WellInfo(0)
      Dim Source As String = WellInfo(1)
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As WellActionDTO = gw.FindWellOrigUOM(TLMId)
      Session("WellActionDTO") = wa

      Master.SetControlValues(wa, False)
      Master.AddControlAttributes()

    End If

  End Sub

  Protected Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click

    Try
      Dim wa As WellActionDTO = CType(Session("WellActionDTO"), WellActionDTO)
      wa.ACTION = WELL_ACTION_ADD_VERSION

      wa = Master.PopulateWellActionDTO(wa)

      If wa.IsWellLicenseChanged Then
        wa.WELL_LICENSE.Rows(0)("WIM_ACTION_CD") = WELL_ACTION_CREATE_WELL
      End If

      If Not wa.IsWellVersionChanged Then
        Dim srMsg As String = "Incomplete data entered to create well. Save to database not done."
        Dim myscript As String = "window.onload = function() {alert('" + srMsg + "');}"
        Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
        Exit Sub
      End If

      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)

      wa = gw.ProcessWellAction(wa)

      If wa.STATUS_CD = WELL_ACTION_COMPLETE Then

        Master.ClearPageSessionVars()
        Page.Response.Redirect("~/WellVersion.aspx?Wellkey=" & Server.HtmlEncode(wa.UWI & "," & wa.SOURCE) & "&Mode=A")

      Else

        Master.ResetControls()
        Master.HandleErrors(wa)

      End If

    Catch ex As Exception
      Throw ex

    End Try

  End Sub

  Protected Sub btnCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCancel.Click

    Master.ClearPageSessionVars()
    Page.Response.Redirect("~/Default.aspx")

  End Sub

#Region "Private Functions"

#End Region

End Class