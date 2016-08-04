Imports System.Net
Imports System.Threading
Imports TalismanEnergy.WIM.GatewayProxy
Imports TalismanEnergy.WIM.Common.AppConstants

Partial Public Class LookUpTable_Load
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    Response.Redirect("~/Default.aspx", False)

    Dim msg As String = " * Loading LookUpTable_Load.aspx under " & Request.ServerVariables("AUTH_USER")
    Diagnostics.Trace.TraceInformation(msg)

    LoadLookUpLists()

  End Sub

  Private WIMLookUpsFilePath As String
  Private WIMLookUps As String
  Private WIMBigLookUp As String

  Sub LoadLookUpLists()

    Diagnostics.Trace.TraceInformation(" * Entering LoadLookUpLists.")
    Try
      Dim IsLookUpListNeedsLoading As Boolean = Not (IsBigLookUpListsLoaded() And IsLookUpListsLoaded())
      Diagnostics.Trace.TraceInformation(" * Lookup table needs loading? {0}.", _
                      IsLookUpListNeedsLoading)
      If IsLookUpListNeedsLoading Then
        WIMLookUps = ConfigurationManager.AppSettings("WIM_LOOKUPTABLES").ToString()
        WIMBigLookUp = ConfigurationManager.AppSettings("WIM_BIG_LOOKUPTABLES").ToString()
        WIMLookUpsFilePath = Server.MapPath("~/App_LocalResources/")

        ' Get the cache from file first to get UI usable
        Diagnostics.Trace.TraceInformation(" * IsLookUpListsLoaded ? {0}.", IsLookUpListsLoaded())
        If Not IsLookUpListsLoaded() Then
          'LoadLookUpListsFromXML(Me.Context)
          'ThreadPool.QueueUserWorkItem(New WaitCallback(AddressOf LoadLookUpListsFromXML), Me.Context)
          Dim LoadLookUpListsFromXML As New Thread(AddressOf Me.LoadLookUpListsFromXML)
          LoadLookUpListsFromXML.Start(Me.Context)
        Else
          Diagnostics.Trace.TraceInformation(" * Small LookUpLists already loaded.")
        End If

        If Not IsBigLookUpListsLoaded() Then
          'LoadBigLookUpListsFromXML(Me.Context)
          'ThreadPool.QueueUserWorkItem(New WaitCallback(AddressOf LoadBigLookUpListsFromXML), Me.Context)
          Dim LoadBigLookUpListsFromXML As New Thread(AddressOf Me.LoadBigLookUpListsFromXML)
          LoadBigLookUpListsFromXML.Start(Me.Context)
        Else
          Diagnostics.Trace.TraceInformation(" * Big LoadLookUpLists already loaded.")
        End If

        'ThreadPool.QueueUserWorkItem(New WaitCallback(AddressOf CallRefreshLookUpTable), Me.Context)

      End If
    Catch ex As Exception
      Diagnostics.Trace.TraceError(" * ERROR: " & ex.ToString)
      'EventLogger.LogEvent(ex.ToString, EventLogEntryType.Error)
      'Thread.CurrentThread.Abort()
      'Throw ex
    Finally
      Diagnostics.Trace.TraceInformation(" * Exiting LoadLookUpLists.")
    End Try
  End Sub

  Sub LoadLookUpListsFromXML(ByVal O As Object)

    Diagnostics.Trace.Indent()
    Diagnostics.Trace.TraceInformation(" ** Entering LoadLookUpListsFromXML in thread {0}.", Thread.CurrentThread.ManagedThreadId)

    Try
      Dim ctx As HttpContext = CType(O, HttpContext)
      Dim lookupFile As String
      Dim tableNames() As String

      Diagnostics.Trace.TraceInformation(" ** Small lookup table list: {0}.", WIMLookUps)
      tableNames = WIMLookUps.Split(",")

      Dim dt As DataTable
      For Each s As String In tableNames
        Try
          dt = New DataTable(s.Trim)
          lookupFile = String.Format("{0}{1}.xml", WIMLookUpsFilePath, dt.TableName)
          dt.ReadXml(lookupFile)
          If dt.TableName = APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA Then
            dt.DefaultView.Sort = "DISPLAY_TEXT"
          End If

          Dim dep As New CacheDependency(lookupFile)
          'If Not ctx.Cache(dt.TableName) Is Nothing Then
          '    ctx.Cache.Remove(dt.TableName)
          'End If
          ctx.Cache.Insert(dt.TableName, dt, dep, DateTime.MaxValue, TimeSpan.Zero, CacheItemPriority.NotRemovable, Nothing)
        Catch ex As Exception
          Diagnostics.Trace.TraceError(" ** ERROR: dt.TableName - " & ex.ToString)
        End Try
        Diagnostics.Trace.TraceInformation(" ** Reading lookup file: {0} into Cache({1}) datatable.", lookupFile, dt.TableName)
      Next


      'Dim RefreshLookUpTable As New Thread(AddressOf Me.RefreshLookUpTable)
      'RefreshLookUpTable.Start()

      Application.Lock()
      Application("IsLookUpListsLoaded") = True
      Application.UnLock()
    Catch ex As Exception
      Application.Lock()
      Application("IsLookUpListsLoaded") = False
      Application.UnLock()
      Diagnostics.Trace.TraceError(" ** ERROR: " & ex.ToString)
      'Thread.CurrentThread.Abort()
      'Throw ex
    Finally
      Diagnostics.Trace.TraceInformation(" ** Exiting LoadLookUpListsFromXML in thread {0}.", Thread.CurrentThread.ManagedThreadId)
      Diagnostics.Trace.Unindent()
    End Try
  End Sub

  Sub LoadBigLookUpListsFromXML(ByVal O As Object)

    Diagnostics.Trace.Indent()
    Diagnostics.Trace.TraceInformation(" *** Entering LoadBigLookUpListsFromXML in thread {0}.", Thread.CurrentThread.ManagedThreadId)

    Try
      Dim ctx As HttpContext = CType(O, HttpContext)
      Dim lookupFile As String
      Dim tableNames() As String
      tableNames = WIMBigLookUp.Split(",")
      Diagnostics.Trace.TraceInformation(" *** Big lookup table list: : {0}.", WIMBigLookUp)

      Dim dt As DataTable
      For Each s As String In tableNames
        Try
          dt = New DataTable(s.Trim)
          lookupFile = String.Format("{0}{1}.xml", WIMLookUpsFilePath, dt.TableName)
          dt.ReadXml(lookupFile)
          If dt.TableName = APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA Then
            dt.DefaultView.Sort = "DISPLAY_TEXT"
          End If
          Dim dep As New CacheDependency(lookupFile)
          ctx.Cache.Insert(dt.TableName, dt, dep, DateTime.MaxValue, TimeSpan.Zero, CacheItemPriority.NotRemovable, Nothing)

        Catch ex As Exception
          Diagnostics.Trace.TraceError(" ** ERROR: dt.TableName - " & ex.ToString)
        End Try
        Diagnostics.Trace.TraceInformation(" *** Reading lookup file: {0} into Cache({1}) datatable.", lookupFile, dt.TableName)
      Next
      Application.Lock()
      Application("IsBigLookUpListsLoaded") = True
      Application.UnLock()
    Catch ex As Exception
      Application.Lock()
      Application("IsBigLookUpListsLoaded") = False
      Application.UnLock()
      Diagnostics.Trace.TraceError(" **** ERROR: " & ex.ToString)
    Finally
      Diagnostics.Trace.TraceInformation(" *** Exiting LoadBigLookUpListsFromXML in thread {0}.", Thread.CurrentThread.ManagedThreadId)
      Diagnostics.Trace.Unindent()
    End Try
  End Sub

  Sub RefreshLookUpTable()
    Try
      Dim url As String = ConfigurationManager.AppSettings("WIM_REFRESH_LOOKUPTABLES_URL").ToString()
      Dim req As WebRequest = WebRequest.Create(url)
      req.Timeout = CType(ConfigurationManager.AppSettings("WIM_REFRESH_LOOKUPTABLES_TIMEOUT"), UInteger)
      Dim res As WebResponse = req.GetResponse()
      res.Close()
    Catch ex As Exception
      Diagnostics.Trace.TraceError(" **** ERROR: " & ex.ToString)
    End Try
  End Sub

  Sub CallRefreshLookUpTable()
    Dim RefreshLookUpTable As New Thread(AddressOf Me.RefreshLookUpTable)
    RefreshLookUpTable.Start()
  End Sub

  Function IsLookUpListsLoaded() As Boolean
    If Application("IsLookUpListsLoaded") Is Nothing Then
      Application.Lock()
      Application.Add("IsLookUpListsLoaded", False)
      Application.UnLock()
    End If

    Return CType(Application("IsLookUpListsLoaded"), Boolean)

  End Function

  Function IsBigLookUpListsLoaded() As Boolean
    If Application("IsBigLookUpListsLoaded") Is Nothing Then
      Application.Lock()
      Application.Add("IsBigLookUpListsLoaded", False)
      Application.UnLock()
    End If

    Return CType(Application("IsBigLookUpListsLoaded"), Boolean)

  End Function

End Class