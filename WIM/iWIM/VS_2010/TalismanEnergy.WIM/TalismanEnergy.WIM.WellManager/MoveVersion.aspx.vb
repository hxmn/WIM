Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class MoveVersion
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    Dim Well(0 To 2) As String   ' 0 not used.
    Dim wellNo As Integer

    If Not Page.IsPostBack Then

      ' Wipe out former session variables unless relying on them to do a move

      If Request.QueryString("MoveTo") Is Nothing Then
        Session("Well1") = Nothing
        Session("Well2") = Nothing
        Session("WIM_MoveVersion_Table") = Nothing
      End If

      ' Best effort to get Session variables Well1 and Well 2 defined and copied into local array Well()

      For wellNo = 1 To 2

        If Not Request.QueryString("Wellkey" & wellNo) Is Nothing Then
          Well(wellNo) = Server.HtmlDecode(Request.QueryString("Wellkey" & wellNo))
          Session("Well" & wellNo) = Well(wellNo)
        Else
          If Not Session("Well" & wellNo) Is Nothing Then
            Well(wellNo) = CType(Session("Well" & wellNo), String)
          End If
        End If

      Next

      SetGridHeaders(Well(1), Well(2))

      ' To do a move, we need:
      ' - Request parameter MoveTo to be 1 or 2
      ' - Request parameter RowIDs to be a comma delimited list of (0-based) row IDs (numbers)
      ' - Session variable Well1 defined
      ' - Session variable Well2 defined
      If (Not Request.QueryString("MoveTo") Is Nothing) AndAlso _
         (Not Request.QueryString("RowIDs") Is Nothing) Then
        Try
          wellNo = Integer.Parse(Server.HtmlDecode(Request.QueryString("MoveTo")))
          If wellNo < 1 Or wellNo > 2 Then
            Throw New Exception("MoveTo must be the target well number: 1 or 2.")
          End If

          Dim rowIdStrings() As String = Server.HtmlDecode(Request.QueryString("RowIDs")).Split(",")
          Dim rowIDs(rowIdStrings.Length - 1) As Integer
          Dim idx As Integer = 0
          For Each rowID As String In rowIdStrings
            rowIDs(idx) = Integer.Parse(rowID)
            idx += 1
          Next

          Well(1) = Session("Well1")
          If Well(1) Is Nothing Then Throw New Exception("Lost track of Well 1 in the current session.")
          Well(2) = Session("Well2")
          If Well(2) Is Nothing Then Throw New Exception("Lost track of Well 2 in the current session.")

          MoveVersions(rowIDs, Well(wellNo))

        Catch ex As Exception
          Dim myscript As String = "window.onload = function() {setTimeout('alert(""" + ex.Message.Replace("\", "\\") + """)',500);}"
          Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
        End Try
      End If

      BuildGrids(Well(1), Well(2))

    End If

    lblMessage.ToolTip = ""

  End Sub

  Sub MoveVersions(ByVal rowIDs() As Integer, _
                   ByVal targetUWI As String)

    Dim versionsDT As DataTable = CType(Session("WIM_MoveVersion_Table"), DataTable)
    Dim permitsDT As DataTable = Session(USER_PERMISSIONS).Tables(USER_MOVE_PERMISSION)
    Dim msg As New StringBuilder()
    Dim invalidCount As Integer = 0

    ' Validate request

    For Each id As Integer In rowIDs
      Dim source As String = versionsDT.Rows(id)("SOURCE").ToString()
      Dim sourceName As String = versionsDT.Rows(id)("SOURCE_SHORT_NAME").ToString()
      Dim valid As Boolean = True
      ' Permitted?
      If permitsDT.Select(String.Format("SOURCE = '{0}'", source)).Length < 1 Then
        msg.Append("\n") _
           .Append(sourceName) _
           .Append(":\n      - You are not authorized to move versions with this source.\n")
        valid = False
      End If
      ' Dup?
      If versionsDT.Select(String.Format("SOURCE = '{0}' And UWI = '{1}'", source, targetUWI)).Length > 0 Then
        If valid Then msg.Append("\n").Append(sourceName).Append(":\n")
        msg.Append("      - A version with this source is already present.\n")
        valid = False
      End If
      If Not valid Then invalidCount += 1
    Next

    ' If any invalid, throw an exception summarizing all reasons

    If invalidCount > 0 Then
      Dim plural As String = IIf(invalidCount > 1, "s", "")
      Throw New Exception(String.Format("No versions were moved.\nThe move request was rejected for the following reason{0}:\n{1}", _
                                        plural, _
                                        msg.ToString()))
    End If

    For Each id As Integer In rowIDs
      versionsDT.Rows(id)("UWI") = targetUWI
    Next

    Session("WIM_MoveVersion_Table") = versionsDT

  End Sub

  Private Sub SetGridHeaders(ByVal Well1 As String, ByVal Well2 As String)

    Dim cw1, cw2 As New WellMoveHeaderDTO

    If Well1 = String.Empty Then
      lblWell1.Text = "Well 1: New Well"
    Else
      cw1 = FindWell(Well1)
      If Not cw1.UWI Is Nothing Then
        lblWell1.Text = "Well 1: " & cw1.UWI & " - " & cw1.WELL_NAME & " - " & cw1.COUNTRY_NAME
      Else
        RemoveWellFromGrid(Well1)
        lblWell1.Text = "Well 1: New Well"
        Well1 = String.Empty
        Session("Well1") = Well1
      End If
    End If

    If Well2 = String.Empty Then
      lblWell2.Text = "Well 2: New Well"
    Else
      cw2 = FindWell(Well2)
      If Not cw2.UWI Is Nothing Then
        lblWell2.Text = "Well 2: " & cw2.UWI & " - " & cw2.WELL_NAME & " - " & cw2.COUNTRY_NAME
      Else
        RemoveWellFromGrid(Well2)
        lblWell2.Text = "Well 2: New Well"
        Well2 = String.Empty
        Session("Well2") = Well2
      End If
    End If

  End Sub

  Private Function FindWell(ByVal iWell As String) As WellMoveHeaderDTO

    Dim cw As WellMoveHeaderDTO

    Try
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)

      cw = gw.GetWell(iWell)

    Catch ex As Exception
      Throw ex

    End Try

    Return cw

  End Function

  Private Sub BuildGrids(ByVal Well1 As String, ByVal Well2 As String)

    Dim dt As New DataTable
    Dim dv1, dv2 As DataView

    Try

      If Session("WIM_MoveVersion_Table") Is Nothing Then
        Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
        Dim gw As New GatewayAccess(dbconnection)

        If Well1 = String.Empty Then
          dt = gw.FindVersionsStdUOM(Well2, "Version")
        ElseIf Well2 = String.Empty Then
          dt = gw.FindVersionsStdUOM(Well1, "Version")
        Else
          dt = gw.FindVersionsStdUOM(Well1 & "," & Well2, "Version")
        End If

        CreateSourceKey(dt)
        Session("WIM_MoveVersion_Table") = dt
      Else
        dt = CType(Session("WIM_MoveVersion_Table"), DataTable)
      End If

      dv1 = New DataView(dt)
      If Well1 = String.Empty Then
        dv1.RowFilter = String.Format("UWI='{0}'", String.Empty)
      Else
        dv1.RowFilter = String.Format("UWI='{0}'", Well1)
      End If

      dv1.Sort = "SOURCE ASC"
      dv1.AllowEdit = True
      DataGrid1.DataSource = dv1
      DataGrid1.DataBind()

      dv2 = New DataView(dt)
      If Well2 = String.Empty Then
        dv2.RowFilter = String.Format("UWI='{0}'", String.Empty)
      Else
        dv2.RowFilter = String.Format("UWI='{0}'", Well2)
      End If

      dv2.Sort = "SOURCE ASC"
      dv2.AllowEdit = True
      DataGrid2.DataSource = dv2
      DataGrid2.DataBind()

    Catch ex As Exception
      Throw ex

    End Try

  End Sub

  Private ctr As Integer = 0

  Sub CreateSourceKey(ByRef dt As DataTable)

    If Not (dt.Columns.Contains("ID") And dt.Columns.Contains("ORIG_UWI")) Then
      dt.Columns.Add("ID", Type.GetType("System.Int32"))
      dt.Columns.Add("ORIG_UWI", Type.GetType("System.String"))
      dt.Columns.Add("MOVE_STATUS", Type.GetType("System.String"))
      For Each dr As DataRow In dt.Rows
        dr("ID") = ctr
        dr("ORIG_UWI") = dr("UWI")
        dr("MOVE_STATUS") = String.Empty
        ctr += 1
      Next
    End If

  End Sub

  Protected Sub btnCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCancel.Click

    Session("Well1") = Nothing
    Session("Well2") = Nothing
    Session("WIM_MoveVersion_Table") = Nothing

    Page.Response.Redirect("~/Default.aspx")

  End Sub

  Private Sub btnReset_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnReset.Click

    Dim key1 As String = String.Empty
    Dim key2 As String = String.Empty

    If Not CType(Session("Well1"), String) Is Nothing Then
      key1 = CType(Session("Well1"), String)
    End If

    If Not CType(Session("Well2"), String) Is Nothing Then
      key2 = CType(Session("Well2"), String)
    End If

    Session("Well1") = Nothing
    Session("Well2") = Nothing
    Session("WIM_MoveVersion_Table") = Nothing

    If key1 = String.Empty Then
      Page.Response.Redirect("~/MoveVersion.aspx" + "?Wellkey2=" + key2)
    ElseIf key2 = String.Empty Then
      Page.Response.Redirect("~/MoveVersion.aspx" + "?Wellkey1=" + key1)
    Else
      Page.Response.Redirect("~/MoveVersion.aspx" + "?Wellkey1=" + key1 + "&Wellkey2=" + key2)
    End If

  End Sub

  Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click

    Dim dt As DataTable = CType(Session("WIM_MoveVersion_Table"), DataTable)
    Dim dv As DataView
    Dim wm As New WellMoveDTO
    Dim Success As Boolean = True
    Dim Well1 As String = CType(Session("Well1"), String)
    Dim Well2 As String = CType(Session("Well2"), String)
    Dim sErrMsg As String = String.Empty
    Dim sToTLMID As String = String.Empty

    dv = New DataView(dt)
    dv.RowFilter = String.Format("UWI<>ORIG_UWI")

    If dv.Count = 0 Then Exit Sub

    Try
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)

      For Each dvr As DataRowView In dv
        If sToTLMID = String.Empty Then
          sToTLMID = dvr.Item("UWI").ToString()
        End If

        wm = New WellMoveDTO
        wm.USERID = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper
        wm.FROM_UWI = dvr.Item("ORIG_UWI").ToString()
        wm.FROM_SOURCE = dvr.Item("SOURCE").ToString()
        wm.TO_UWI = dvr.Item("UWI").ToString()

        If wm.TO_UWI = String.Empty Then
          wm.TO_UWI = sToTLMID
        End If

        wm = gw.CallWellMoveSP(wm)

        If wm.STATUS = WELL_MOVE_SUCCESSFUL Then
          dvr.Item("MOVE_STATUS") = "SUCCESS"

          If sToTLMID = String.Empty Then
            sToTLMID = wm.TO_UWI.ToString
            If Well1 = String.Empty Then
              Well1 = wm.TO_UWI.ToString
              Session("Well1") = Well1
            ElseIf Well2 = String.Empty Then
              Well2 = wm.TO_UWI.ToString
              Session("Well2") = Well2
            End If
            AddNewWellToGrid(wm.TO_UWI.ToString)
          End If
        Else
          Success = False
          sErrMsg = "Please review and resubmit the moves for these wells, as a failure in one or more moves has occurred.\n"
          sErrMsg += "- " & wm.ERRORMSG.Substring(wm.ERRORMSG.IndexOf(",") + 1) & "\n\n"
          Exit For
        End If
      Next

      If Success Then
        lblMessage.Text = "Move Version(s) - SUCCESSFUL!"
        lblMessage.ForeColor = Drawing.Color.DarkGreen
      Else
        dt = CType(Session("WIM_MoveVersion_Table"), DataTable)
        dv = New DataView(dt)
        dv.RowFilter = "UWI<>ORIG_UWI AND MOVE_STATUS<>'SUCCESS'"
        If dv.Count > 0 Then
          sErrMsg += "Versions not moved due to error above:\n"
          For Each dvr As DataRowView In dv
            sErrMsg += "- " & dvr("SOURCE") & " from " & dvr("ORIG_UWI") & " to " & dvr("UWI") & "\n"
          Next
        End If
        sErrMsg += "\n" & "If this error persists, please contact TIS Group for assistance.\n"
        Dim myscript As String = "window.onload = function() {alert('" + sErrMsg + "');}"
        Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)

        lblMessage.Text = "Move Version(s) - FAILED! "
        lblMessage.ToolTip = sErrMsg.Replace("\n", vbCrLf).ToString()
        lblMessage.ForeColor = Drawing.Color.DarkRed
      End If

      Session("WIM_MoveVersion_Table") = Nothing
      SetGridHeaders(Well1, Well2)
      BuildGrids(Well1, Well2)

    Catch ex As Exception
      Throw ex

    End Try

  End Sub

  Private Sub AddNewWellToGrid(ByVal TLMId As String)

    Dim sTLMIds As String

    If Not Session("SearchedWells") Is Nothing Then
      sTLMIds = CType(Session("SearchedWells"), String)
      sTLMIds = sTLMIds & "," & TLMId
      Session("SearchedWells") = sTLMIds
    Else
      Session("SearchedWells") = TLMId
    End If

  End Sub

  Private Sub RemoveWellFromGrid(ByVal TLMId As String)

    Dim aTLMIds() As String
    Dim sTLMIds As String = String.Empty

    If Not Session("SearchedWells") Is Nothing Then
      aTLMIds = CType(Session("SearchedWells"), String).Split(",")

      For Each s As String In aTLMIds
        If s <> TLMId Then
          sTLMIds += s + ","
        End If
      Next

      If sTLMIds.EndsWith(",") Then
        sTLMIds = sTLMIds.Remove(sTLMIds.Length - 1, 1)
      End If

      Session("SearchedWells") = sTLMIds

    End If

  End Sub

End Class