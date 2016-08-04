Imports System.Web.SessionState
Imports TalismanEnergy.WIM.GatewayProxy
Imports TalismanEnergy.WIM.Common.AppConstants

Public Class Global_asax
  Inherits System.Web.HttpApplication

  Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires when the application is started
    Dim appName As String = ConfigurationManager.AppSettings("APP_NAME")
    Dim appVersion As String = ConfigurationManager.AppSettings("APP_VERSION")
    LogEvent(String.Format("{0} {1} started on {2}.", _
                           appName, _
                           appVersion, _
                           Now), _
             EventLogEntryType.Information)
  End Sub

  Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires when the session is started 
    LogEvent(String.Format("New session {0} for {1} started on {2}.", _
                       Session.SessionID, _
                       Request.ServerVariables("AUTH_USER"), _
                       Now), _
         EventLogEntryType.Information)

    GetUserPermissions()
  End Sub

  Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires at the beginning of each request
  End Sub

  Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires upon attempting to authenticate the user
  End Sub

  Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires when an error occurs
    Dim ErrorMessage As String

    'create the error message 
    ErrorMessage = GetErrorMessage()

    'Insert error information into the event log
    LogEvent(ErrorMessage, EventLogEntryType.Error)

    'clear the error and redirect to the error page 
    Server.Transfer("/ErrorMessage.aspx?ErrorMessage=" & ErrorMessage)
  End Sub

  Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires when the session ends
    LogEvent(String.Format("Session {0} ended on {1}.", _
                       Session.SessionID, _
                       Now), _
         EventLogEntryType.Information)
  End Sub

  Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
    ' Fires when the application ends
    Dim appName As String = ConfigurationManager.AppSettings("APP_NAME")
    Dim appVersion As String = ConfigurationManager.AppSettings("APP_VERSION")
    LogEvent(String.Format("{0} {1} ended on {2}.", _
                           appName, _
                           appVersion, _
                           Now), _
             EventLogEntryType.Information)
  End Sub

  Sub GetUserPermissions()

    Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
    Dim gw As New GatewayAccess(dbconnection)
    Dim ds As New DataSet

    'If ConfigurationManager.AppSettings("DemoCachedDataMode").ToString() = "TRUE" Then
    '    ds.ReadXml(Server.MapPath("App_LocalResources/WIMPermissions.xml"), XmlReadMode.ReadSchema)
    'Else
    Dim userID As String = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper

    If userID = ConfigurationManager.AppSettings("UserLogin").ToString() Then
      If ConfigurationManager.AppSettings("AdminAccess").ToString() = "TRUE" Then
        userID = userID + "ADM"
      Else
        If ConfigurationManager.AppSettings("NoAccess").ToString() = "TRUE" Then
          userID = userID + "TST"
        End If
      End If
    Else
      If userID = ConfigurationManager.AppSettings("UserLoginAdmin").ToString() Then
        If ConfigurationManager.AppSettings("AdminAccess").ToString() = "FALSE" Then
          userID = userID.Remove(7, 3)
        Else
          If ConfigurationManager.AppSettings("NoAccess").ToString() = "TRUE" Then
            userID = userID + "TST"
          End If
        End If
      End If
    End If

    ds = gw.GetUserPermissions(userID)
    'ds.WriteXml(Server.MapPath("App_LocalResources/WIMPermissions.xml"), XmlWriteMode.WriteSchema)

    'End If

    Session(USER_PERMISSIONS) = ds

    Session("CreatePermission") = IIf(ds.Tables(USER_CREATE_PERMISSION).Rows.Count = 0, False, True)
    Session("AddPermission") = IIf(ds.Tables(USER_ADD_PERMISSION).Rows.Count = 0, False, True)
    Session("UpdatePermission") = IIf(ds.Tables(USER_UPDATE_PERMISSION).Rows.Count = 0, False, True)
    Session("InactivatePermission") = IIf(ds.Tables(USER_INACTIVATE_PERMISSION).Rows.Count = 0, False, True)
    Session("DeletePermission") = IIf(ds.Tables(USER_DELETE_PERMISSION).Rows.Count = 0, False, True)
    Session("MovePermission") = IIf(ds.Tables(USER_MOVE_PERMISSION).Rows.Count = 0, False, True)

  End Sub

  Sub LogEvent(ByVal Message As String, ByVal Type As EventLogEntryType)

    Const EVENT_LOG_NAME As String = "WIM.iWIM"

    Dim Log As EventLog = New EventLog
    Log.Source = EVENT_LOG_NAME
    Log.WriteEntry(Message, Type)

  End Sub

  Function GetErrorMessage() As String
    ' Get last exception error message, format it for display
    Dim lastException As Exception

    'get the last error that occurred
    lastException = Server.GetLastError()

    'create the error message 
    Dim sMessage As String
    If lastException Is Nothing Then
      sMessage = "Unknown exception - no last server error"
    Else
      sMessage = lastException.Message & _
                 vbCrLf & vbCrLf & _
                 lastException.ToString()
    End If

    Server.ClearError()

    Return sMessage

  End Function

End Class