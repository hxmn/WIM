Public Class Reset
    Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    Session.Clear()
    Session.Abandon()
    Response.Cookies("ASP.NET_SessionId").Expires = DateTime.Now.AddYears(-1)
    Response.Redirect("~/LookUpTable_Load.aspx", True)
    Response.Cache.SetNoStore()
    Response.CacheControl = "no-cache"

  End Sub

End Class