Public Partial Class ErrorMessage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim ErrorMessage As String = Request.QueryString("ErrorMessage")

        txtErrorMessage.Text = ErrorMessage

        Server.ClearError()

    End Sub

End Class