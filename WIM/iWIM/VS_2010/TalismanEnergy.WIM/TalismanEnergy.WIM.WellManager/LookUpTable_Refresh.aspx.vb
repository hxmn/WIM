Imports System.Threading
Imports TalismanEnergy.WIM.GatewayProxy
Imports TalismanEnergy.WIM.Common.AppConstants

Partial Public Class LookUpTable_Refresh
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    Dim sMsg As String = " **** Loading LookUpTable_Refresh.aspx under " & Request.ServerVariables("AUTH_USER")
    sLogMessage += sMsg + vbCrLf
    Diagnostics.Trace.TraceInformation(sMsg)

    LoadLookUpListsFromDB(Me.Context)

    sMsg = " **** Exiting LookUpTable_Refresh.aspx."
    sLogMessage += sMsg + vbCrLf
    Diagnostics.Trace.TraceInformation(sMsg)
    WriteToEventLog(sLogMessage, EventLogEntryType.Information)

  End Sub

  Sub LoadLookUpListsFromDB(ByVal O As Object)

    Diagnostics.Trace.Indent()
    Diagnostics.Trace.TraceInformation(" **** Entering LoadLookUpListsFromDB in Worker thread {0}.", Thread.CurrentThread.ManagedThreadId)

    Dim sMsg As String
    Try
      Dim WIMLookUps As String = Server.HtmlDecode(Request.QueryString("table"))
      WIMLookUps = IIf(WIMLookUps Is Nothing, String.Empty, WIMLookUps)
      sMsg = String.Format(" **** Refreshing lookup table: {0}.", WIMLookUps)
      sLogMessage += sMsg + vbCrLf

      Dim WIMLookUpsFilePath As String = Server.MapPath("~/App_LocalResources/")
      Dim WIMLookUpsFile As String = Server.MapPath("~/App_LocalResources/WIMLookUps.xml")
      Dim WIMDbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()

      Dim ctx As HttpContext = CType(O, HttpContext)
      Dim gw As New GatewayAccess(WIMDbconnection)
      Dim ds As New DataSet
      Dim lookupFile As String

      Dim GetFromLocalDB As Boolean = ConfigurationManager.AppSettings("DemoCachedDataMode").ToString().ToUpper() = "TRUE"
      Diagnostics.Trace.TraceInformation(" **** GetFromLocalDB ? {0}.", GetFromLocalDB)
      If GetFromLocalDB Then
        ds.ReadXml(WIMLookUpsFile, XmlReadMode.ReadSchema)
      ElseIf (WIMLookUps.Length = 0) Then
        ds = gw.GetLookUpTables
        ds.WriteXml(WIMLookUpsFile, XmlWriteMode.WriteSchema)
        Diagnostics.Trace.TraceInformation(" **** gw.GetLookUpTables writes to WIMLookUpsFile: {0}.", WIMLookUpsFile)
      Else
        ds = gw.GetLookUpTables(WIMLookUps)
      End If

      Dim dt As DataTable
      For Each dt In ds.Tables
        If WIMLookUps.Contains(dt.TableName) Or WIMLookUps.Length = 0 Then
          lookupFile = String.Format("{0}{1}.xml", WIMLookUpsFilePath, dt.TableName)
          If Not Cache(dt.TableName) Is Nothing Then
            Cache.Remove(dt.TableName)
          End If
          dt.WriteXml(lookupFile, XmlWriteMode.WriteSchema)

          Dim dep As New CacheDependency(lookupFile)
          Cache.Insert(dt.TableName, dt, dep, Cache.NoAbsoluteExpiration, Cache.NoSlidingExpiration, CacheItemPriority.NotRemovable, Nothing)

          sMsg = String.Format(" **** Updating lookup file: {0}.", lookupFile)
          sLogMessage += sMsg + vbCrLf
          Diagnostics.Trace.TraceInformation(sMsg)
        End If
      Next
    Catch ex As Exception
      sMsg = String.Format(" **** ERROR: {0}.", ex.ToString)
      sLogMessage += sMsg + vbCrLf
      Diagnostics.Trace.TraceError(sMsg)
      'Thread.CurrentThread.Abort()
      'Throw ex
    Finally
      Diagnostics.Trace.TraceInformation(" **** Exiting LoadLookUpListsFromDB in Worker thread {0}.", Thread.CurrentThread.ManagedThreadId)
      Diagnostics.Trace.Unindent()
    End Try

  End Sub

  Private sLogMessage As String = Nothing
  Const EVENT_LOG_NAME As String = "WIM.iWIM"

  Sub WriteToEventLog(ByVal Message As String, ByVal Type As EventLogEntryType)

    Dim Log As EventLog = New EventLog
    Log.Source = EVENT_LOG_NAME
    Log.WriteEntry(Message, Type)

  End Sub

End Class
