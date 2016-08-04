Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class WellVersion
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack _
            And Not DataGrid1.CausedCallback Then

            Dim WellInfo() As String = Server.HtmlDecode(Request.QueryString("Wellkey")).Split(",")
            Dim Mode As String = Request.QueryString("Mode")
            Dim TLMId As String = WellInfo(0)
            Dim Source As String = WellInfo(1)

            Select Case Mode
                Case "E"
                    lblWellVersion.Text = "Edit Version - TLM ID [" & TLMId & "] Source [" & Source & "] - SUCCESSFUL!"
                    Page.Title = "iWIM - Edit Version"
                Case "A"
                    lblWellVersion.Text = "Add Version - TLM ID [" & TLMId & "] Source [" & Source & "] - SUCCESSFUL!"
                    Page.Title = "iWIM - Add Version"
                Case "C"
                    lblWellVersion.Text = "Create Well - TLM ID [" & TLMId & "] - SUCCESSFUL!"
                    Page.Title = "iWIM - Create Well"
                Case Else
                    lblWellVersion.Text = ""
                    Page.Title = "iWIM - Well Version"
            End Select

            SetControlValues(TLMId, Source)
            SetUserPermission(Source)

        End If

    End Sub

    Protected Sub btnEditVersion_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnEditVersion.Click

        Page.Response.Redirect("~/EditWell.aspx?Wellkey=" & Server.HtmlEncode(Server.HtmlDecode(Request.QueryString("Wellkey"))))

    End Sub

    Protected Sub btnAddVersion_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnAddVersion.Click

        Page.Response.Redirect("~/AddVersion.aspx?Wellkey=" & Server.HtmlEncode(Server.HtmlDecode(Request.QueryString("Wellkey"))))

    End Sub

    Private Sub SetControlValues(ByVal TLMId As String, ByVal Source As String)

        Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
        Dim gw As New GatewayAccess(dbconnection)
        Dim wa As New WellActionDTO(gw.GetVersion(TLMId, Source))

        txtddlSource.Text = wa.SOURCE_NAME
        lblSource2val.Text = txtddlSource.Text

        lblTLMIDval.Text = wa.UWI
        lblTLMID2val.Text = lblTLMIDval.Text

        txtUWI.Text = wa.IPL_UWI_LOCAL
        lblUWI2val.Text = txtUWI.Text

        txtddlCountry.Text = wa.COUNTRY_NAME
        lblCountry2val.Text = txtddlCountry.Text

        txtWellName.Text = wa.WELL_NAME
        lblWellName2val.Text = txtWellName.Text

        txtPlotName.Text = wa.PLOT_NAME

        txtddlOnOffShoreInd.Text = wa.IPL_OFFSHORE_IND
        txtddlWellProfileType.Text = wa.PROFILE_TYPE_NAME
        txtddlCurrentStatus.Text = wa.CURRENT_STATUS_NAME
        txtddlOperator.Text = wa.WV_OPERATOR_NAME
        txtddlLicensee.Text = wa.IPL_LICENSEE_NAME

        txtGroundElev.Text = wa.GROUND_ELEV
        txtddlGroundElevUnits.Text = wa.GROUND_ELEV_OUOM

        txtKBElev.Text = wa.KB_ELEV
        txtddlKBElevUnits.Text = wa.KB_ELEV_OUOM

        txtRotaryTableElev.Text = wa.ROTARY_TABLE_ELEV

        txtDerrickFloor.Text = wa.DERRICK_FLOOR_ELEV
        txtddlDerrickFloorUnits.Text = wa.DERRICK_FLOOR_ELEV_OUOM

        txtWaterDepth.Text = wa.WATER_DEPTH
        txtddlWaterDepthUnits.Text = wa.WATER_DEPTH_OUOM

        txtCasingFlange.Text = wa.CASING_FLANGE_ELEV
        txtddlCasingFlangeUnits.Text = wa.CASING_FLANGE_ELEV_OUOM

        txtTotalDepth.Text = wa.DRILL_TD
        txtddlTotalDepthUnits.Text = wa.DRILL_TD_OUOM

        txtLicenseNumber.Text = wa.LICENSE_NUM
        txtLicenseDate.Text = wa.LICENSE_DATE
        txtRigReleaseDate.Text = wa.RIG_RELEASE_DATE
        txtSpudDate.Text = wa.SPUD_DATE
        txtFinalDrillDate.Text = wa.FINAL_DRILL_DATE

        txtBasin.Text = wa.IPL_BASIN
        txtArea.Text = wa.IPL_AREA
        txtBlock.Text = wa.IPL_BLOCK

        txtddlProvState.Text = wa.PROVINCE_STATE_NAME
        txtddlCounty.Text = wa.COUNTY_NAME
        txtDistrict.Text = wa.DISTRICT

        txtLeaseName.Text = wa.LEASE_NAME
        txtAssignedField.Text = wa.ASSIGNED_FIELD
        txtPool.Text = wa.IPL_POOL

        txtddlOldestStratAge.Text = wa.OLDEST_STRAT_UNIT_ID
        txtddlTDStratAge.Text = wa.TD_STRAT_UNIT_ID

        txtPlugbackDepth.Text = wa.PLUGBACK_DEPTH
        txtddlPlugbackDepthUnits.Text = wa.PLUGBACK_DEPTH_OUOM

        txtPlugbackTVD.Text = wa.IPL_PLUGBACK_TVD

        txtMaxTVD.Text = wa.MAX_TVD
        txtddlMaxTVDUnits.Text = wa.MAX_TVD_OUOM

        DataGrid1.DataSource = wa.WELL_NODE_VERSION
        DataGrid1.DataBind()

    End Sub

    Private Sub SetUserPermission(ByVal Source As String)

        Dim dt As DataTable = CType(Session("UserPermissions"), DataSet).Tables(USER_UPDATE_PERMISSION)
        Dim dv As DataView

        dv = New DataView(dt)
        dv.RowFilter = "SOURCE='" & Source & "'"

        If Not dv.Count = 0 Then
            btnEditVersion.Enabled = True
        Else
            btnEditVersion.Enabled = False
        End If

        If CType(Session("AddPermission"), Boolean) Then
            btnAddVersion.Enabled = True
        Else
            btnAddVersion.Enabled = False
        End If

    End Sub

End Class