Public Class WellMoveDTO

    Public FROM_UWI As String
    Public FROM_SOURCE As String
    Public TO_UWI As String
    Public STATUS As Integer
    Public INTERACTIVE As Boolean = True
    Public ERRORMSG As String

End Class

Public Class WellMoveHeaderDTO

    Public UWI As String
    Public WELL_NAME As String
    Public COUNTRY As String
    Public COUNTRY_NAME As String
    Public IPL_UWI_LOCAL As String
    Public ERRORMSG As String

End Class
