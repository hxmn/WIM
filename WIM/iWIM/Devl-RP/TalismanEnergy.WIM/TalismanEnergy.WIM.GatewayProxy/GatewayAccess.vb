Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.DataAccess

Public Class GatewayAccess

    Private _InitString As String

    Public Sub New(ByVal InitString As String)

        _InitString = InitString

    End Sub

    Public Function ValidateUser(ByVal iUserIdentity As String) As Boolean

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.ValidateUser(iUserIdentity)

    End Function

    Public Function GetUserPermissions(ByVal iuserID As String) As DataSet

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetUserPermissions(iuserID)

    End Function

    Public Function ProcessWellAction(ByVal iwa As WellActionDTO) As WellActionDTO

        Dim WIMda As New DBAccess(_InitString)
        Dim wa As WellActionDTO

        wa = WIMda.ProcessWellAction(iwa)

        Return wa

    End Function

    Public Function CallWellMoveSP(ByVal iwm As WellMoveDTO) As WellMoveDTO

        Dim WIMda As New DBAccess(_InitString)
        Dim wm As WellMoveDTO

        wm = WIMda.CallWellMoveSP(iwm)

        Return wm

    End Function

    Public Function GetWell(ByVal iWell As String) As WellMoveHeaderDTO

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetWell(iWell)

    End Function

    Public Function FindWellOrigUOM(ByVal iWell As String) As WellActionDTO

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindWellOrigUOM(iWell)

    End Function

    Public Function FindWellsStdUOM(ByVal iWellList As String, ByVal iTableName As String) As DataTable

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindWellsStdUOM(iWellList, iTableName)

    End Function

    Public Function GetVersionOrigUOM(ByVal iTLMID As String, ByVal iSource As String) As DataSet

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetVersionOrigUOM(iTLMID, iSource)

    End Function

    Public Function FindVersionsOrigUOM(ByVal iWellList As String, ByVal iTableName As String) As DataTable

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindVersionsOrigUOM(iWellList, iTableName)

    End Function

    Public Function FindVersionsStdUOM(ByVal iWellList As String, ByVal iTableName As String) As DataTable

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindVersionsStdUOM(iWellList, iTableName)

    End Function

    Public Function GetLookUpTables() As DataSet

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetLookUpTables(String.Empty)

  End Function

  Public Function GetLookUpTables(ByVal LookUpList As String) As DataSet

    Dim WIMda As New DBAccess(_InitString)

    Return WIMda.GetLookUpTables(LookUpList)

  End Function

  Public Function GetFilteredBAList(ByVal filter As String, ByVal maxRows As Integer) As DataRow()

    Dim WIMda As New DBAccess(_InitString)

    Return WIMda.GetFilteredBAList(filter, maxRows)

  End Function

  Public Function GetDBName() As String

    Dim WIMda As New DBAccess(_InitString)

    Return WIMda.getDBName()

  End Function

  Public Function FindWellTLMID(ByVal aliasType As String, _
                                ByVal aliasValue As String) _
  As String
    Dim WIMda As New DBAccess(_InitString)

    Return WIMda.CallFindWellSP(aliasType, aliasValue)

  End Function

End Class
