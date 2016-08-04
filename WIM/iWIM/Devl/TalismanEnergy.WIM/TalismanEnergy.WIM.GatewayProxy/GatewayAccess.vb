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

    Public Function FindWell(ByVal iWell As String) As WellActionDTO

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindWell(iWell)

    End Function

    Public Function FindWells(ByVal iWellList As String, ByVal iTableName As String) As DataTable

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindWells(iWellList, iTableName)

    End Function

    Public Function GetVersion(ByVal iTLMID As String, ByVal iSource As String) As DataSet

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetVersion(iTLMID, iSource)

    End Function

    Public Function FindVersions(ByVal iWellList As String, ByVal iTableName As String) As DataTable

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.FindVersions(iWellList, iTableName)

    End Function

    Public Function GetLookUpTables() As DataSet

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetLookUpTables(String.Empty)

    End Function

    Public Function GetLookUpTables(ByVal LookUpList As String) As DataSet

        Dim WIMda As New DBAccess(_InitString)

        Return WIMda.GetLookUpTables(LookUpList)

    End Function

End Class
