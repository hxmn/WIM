Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class CreateWell
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    If Not Page.IsPostBack And Not Master.ControlCausedCallback Then

      Master.Permission = USER_CREATE_PERMISSION
      Master.ClearPageSessionVars()
      Master.InitializeLookUpListControls()

      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As New WellActionDTO(gw.GetVersionOrigUOM("", ""))
      Session("WellActionDTO") = wa

      CType(Master.FindControl("lblTLMIDval"), Label).Visible = False
      CType(Master.FindControl("lblTLMIDvalGen"), Label).Visible = True
      CType(Master.FindControl("lblTLMID2val"), Label).Visible = False
      'CType(Master.FindControl("lblTLMID2valGen"), Label).Visible = True

      Master.AddControlAttributes()

    End If

  End Sub

  Protected Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click

    Try
      Dim wa As WellActionDTO = CType(Session("WellActionDTO"), WellActionDTO)
      wa.ACTION = WELL_ACTION_CREATE_WELL

      wa = Master.PopulateWellActionDTO(wa)

      If wa.PROFILE_TYPE = VERTICAL Then
        wa.PLUGBACK_DEPTH_OUOM = Nothing
        wa.IPL_PLUGBACK_TVD = Nothing
        wa.MAX_TVD = Nothing
        wa.MAX_TVD_OUOM = Nothing
      End If

      wa.IsWellVersionChanged = _
         Not String.IsNullOrEmpty(wa.SOURCE) OrElse _
         Not String.IsNullOrEmpty(wa.IPL_UWI_LOCAL) OrElse _
         Not String.IsNullOrEmpty(wa.COUNTRY) OrElse _
         Not String.IsNullOrEmpty(wa.WELL_NAME)

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

        AddNewWellToGrid(wa.UWI)
        Master.ClearPageSessionVars()
        Page.Response.Redirect("~/WellVersion.aspx?Wellkey=" & Server.HtmlEncode(wa.UWI & "," & wa.SOURCE) & "&Mode=C")

      Else

        Master.ResetControls()
        Master.HandleErrors(wa)

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

#Region "Private Functions"

  Private Sub AddNewWellToGrid(ByVal TLMId As String)

    Dim sTLMIds As String

    If Not Session("SearchedWells") Is Nothing Then
      sTLMIds = CType(Session("SearchedWells"), String)
      sTLMIds = sTLMIds & "," & TLMId
      Session("SearchedWells") = sTLMIds
    Else
      Session("SearchedWells") = TLMId
    End If

  End Sub

#End Region

End Class