Imports System
Imports System.Net
Imports System.Configuration
Imports System.Security.Principal

Module LookUpsRefresh

    Sub Main()

        Try
            AppDomain.CurrentDomain.SetPrincipalPolicy(PrincipalPolicy.WindowsPrincipal)
            'Dim user As WindowsPrincipal = CType(System.Threading.Thread.CurrentPrincipal, WindowsPrincipal)
            Dim ident As WindowsIdentity = WindowsIdentity.GetCurrent()
            Dim user As New WindowsPrincipal(ident)
            'ident.Token.


            Dim sMsg As String = String.Format("LookUps Refresh started on {3}. {0}Url=""{1}""{0}Timeout={2}{0}User={4}.", _
                                                vbCrLf, _
                                                My.Settings.WIM_REFRESH_LOOKUPTABLES_URL, _
                                                My.Settings.Timeout, _
                                                DateTime.Now.ToString(), user.Identity.Name)

            WriteToEventLog(sMsg, EventLogEntryType.Information)
            Dim url As String = My.Settings.WIM_REFRESH_LOOKUPTABLES_URL
            Dim req As WebRequest = WebRequest.Create(url)
            'req.Credentials = New System.Net.NetworkCredential("user", "pw", "CALGARY)
            'req.Credentials = New System.Net.NetworkCredential("WIMINT_SVC", "neg7crE6evutrur3", "CALGARY")
            'req.Credentials = New System.Net.NetworkCredential(user.Identity.Name, user.Identity.Name)

            Dim myCredentials As ICredentials = CredentialCache.DefaultNetworkCredentials
            req.Credentials = myCredentials.GetCredential(New Uri(url), "Basic")

            req.Timeout = My.Settings.Timeout
            Dim res As WebResponse = req.GetResponse()
            res.Close()

        Catch ex As Exception
            Diagnostics.Trace.TraceError(Date.Now.ToString + " **** ERROR: " & ex.ToString)
            WriteToEventLog("LookUps Refresh encountered an error! " + vbCrLf + ex.ToString, EventLogEntryType.Error)
        Finally
            WriteToEventLog("LookUps Refresh ended.", EventLogEntryType.Information)
        End Try

    End Sub

    Const EVENT_LOG_NAME As String = "WIM.iWIMLookUpsRefresh"

    Sub WriteToEventLog(ByVal Message As String, ByVal Type As EventLogEntryType)

        Dim Log As EventLog = New EventLog
        Log.Source = EVENT_LOG_NAME
        Log.WriteEntry(Message, Type)

    End Sub

End Module
