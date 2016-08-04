Imports System.Web
Imports System.Web.Services
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.iWIM.WellVersionDetail


Public Class RequestHandler
  Implements IHttpHandler, IRequiresSessionState

  Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest

    context.Response.ContentType = "text/plain"
    Dim nvp As NameValueCollection = context.Request.Params
    Dim ds As DataSet = CType(context.Session("WIM_LocationInfo"), DataSet)

    Select Case (nvp("req"))
      Case "addLocation"
        WellVersionDetail.addLocationGridRow(ds, nvp)
        context.Response.Write("Added")
      Case "updateLocation"
        Dim listId As String = nvp("LIST_ID")
        WellVersionDetail.updateLocationGridRow(ds, listId, nvp)
        context.Response.Write("Updated")
    End Select


  End Sub

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class