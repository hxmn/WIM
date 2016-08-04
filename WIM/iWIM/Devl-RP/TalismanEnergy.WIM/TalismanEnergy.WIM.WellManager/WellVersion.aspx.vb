Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class WellVersion
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    If Not Page.IsPostBack And Not Master.ControlCausedCallback Then

      Dim WellInfo() As String = Server.HtmlDecode(Request.QueryString("Wellkey")).Split(",")
      Dim Mode As String = Request.QueryString("Mode")
      Dim TLMId As String = WellInfo(0)
      Dim Source As String = WellInfo(1)
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As New WellActionDTO(gw.GetVersionOrigUOM(TLMId, Source))

      Dim lblError As Label = Master.FindControl("lblError")
      lblError.ForeColor = Drawing.Color.DarkGreen

      Select Case Mode
        Case "E"
          lblError.Text = "Edit Version - TLM ID [" & TLMId & "] Source [" & Source & "] - SUCCESSFUL!"
        Case "A"
          lblError.Text = "Add Version - TLM ID [" & TLMId & "] Source [" & Source & "] - SUCCESSFUL!"
        Case "C"
          lblError.Text = "Create Well - TLM ID [" & TLMId & "] - SUCCESSFUL!"
        Case Else
          lblError.Text = ""
      End Select

      Master.SetControlValues(wa, True)
      Master.SetReadOnly()
      SetUserPermission(Source)

    End If

  End Sub

  Protected Sub btnEditVersion_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnEditVersion.Click

    Page.Response.Redirect("~/EditWell.aspx?Wellkey=" & Server.HtmlEncode(Server.HtmlDecode(Request.QueryString("Wellkey"))))

  End Sub

  Protected Sub btnAddVersion_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnAddVersion.Click

    Page.Response.Redirect("~/AddVersion.aspx?Wellkey=" & Server.HtmlEncode(Server.HtmlDecode(Request.QueryString("Wellkey"))))

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