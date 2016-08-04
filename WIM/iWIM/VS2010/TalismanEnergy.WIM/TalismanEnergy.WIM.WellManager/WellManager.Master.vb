Imports TalismanEnergy.WIM.Common.AppConstants
Imports ComponentArt.Web.UI
Imports TalismanEnergy.WIM.GatewayProxy

Partial Public Class WellManager
  Inherits System.Web.UI.MasterPage

  Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init

    Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
    Dim gw As New GatewayAccess(dbconnection)
    Dim dbName As String = gw.GetDBName()
    Dim appName As String = ConfigurationManager.AppSettings("APP_NAME")
    Dim appVersion As String = ConfigurationManager.AppSettings("APP_VERSION")

    LabelApp.Text = appName + " " + appVersion + " @ " + dbName + "<br />" + _
                    Request.ServerVariables("AUTH_USER")
    LabelCopyright.Text = "Need help? Contact <a href=""mailto:zTIS_Support?Subject=iWIM Help Request"">TIS Support</a><br />" + _
                          ConfigurationManager.AppSettings("COPYRIGHT")
    LinkReset.ToolTip = "Destroy sessionId: " + Session.SessionID

  End Sub

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    SecureButton(ButtonCreate, "CreatePermission")

    If ConfigurationManager.AppSettings("DataFinderURL") Is Nothing Then
      ButtonSearch.Enabled = False
      ButtonSearch.ToolTip = "DataFinder search is not available"
    End If

  End Sub
  Private Sub SecureButton(ByRef button As Button, ByVal permission As String)

    If Not Session(permission) Is Nothing Then
      If Not CType(Session(permission), Boolean) Then
        button.Enabled = False
        button.PostBackUrl = ""
      End If
    End If

  End Sub

  Private Sub ButtonCreate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles ButtonCreate.Click

    Response.Redirect("~/CreateWell.aspx")

  End Sub

End Class