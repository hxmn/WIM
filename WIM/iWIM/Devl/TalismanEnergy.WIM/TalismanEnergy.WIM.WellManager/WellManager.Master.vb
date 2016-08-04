Imports TalismanEnergy.WIM.Common.AppConstants
Imports ComponentArt.Web.UI

Partial Public Class WellManager
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        SecureButton(ButtonCreate, "CreatePermission")

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