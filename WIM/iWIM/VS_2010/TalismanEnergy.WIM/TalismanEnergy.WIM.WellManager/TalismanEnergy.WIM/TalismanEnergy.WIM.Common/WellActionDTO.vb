Imports System.Xml.Serialization

<Serializable()> _
Public Class WellActionDTO

  Private _IsWellVersionChanged As Boolean
  Public Property IsWellVersionChanged() As Boolean
    Get
      Return _IsWellVersionChanged
    End Get
    Set(ByVal value As Boolean)
      _IsWellVersionChanged = value
    End Set
  End Property

  Private _IsWellLicenseChanged As Boolean
  Public Property IsWellLicenseChanged() As Boolean
    Get
      Return _IsWellLicenseChanged
    End Get
    Set(ByVal value As Boolean)
      _IsWellLicenseChanged = value
    End Set
  End Property

  Private _IsWellNodeVersionChanged As Boolean
  Public Property IsWellNodeVersionChanged() As Boolean
    Get
      Return _IsWellNodeVersionChanged
    End Get
    Set(ByVal value As Boolean)
      _IsWellNodeVersionChanged = value
    End Set
  End Property

  Private _STG_ID As Integer
  Public Property STG_ID() As Integer
    Get
      Return _STG_ID
    End Get
    Set(ByVal value As Integer)
      _STG_ID = value
      WELL_VERSION.Rows(0)("WIM_STG_ID") = value
      WELL_LICENSE.Rows(0)("WIM_STG_ID") = value
    End Set
  End Property

  Private _ACTION As String
  Public Property ACTION() As String
    Get
      Return _ACTION
    End Get
    Set(ByVal value As String)
      _ACTION = value
      WELL_VERSION.Rows(0)("WIM_ACTION_CD") = value
      WELL_LICENSE.Rows(0)("WIM_ACTION_CD") = value
    End Set
  End Property

  Public Property UWI() As String
    Get
      Return WELL_VERSION.Rows(0)("UWI").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("UWI") = value
      WELL_LICENSE.Rows(0)("UWI") = value
    End Set
  End Property

  Public Property SOURCE() As String
    Get
      Return WELL_VERSION.Rows(0)("SOURCE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("SOURCE") = value
      WELL_LICENSE.Rows(0)("SOURCE") = value
    End Set
  End Property

  Public Property SOURCE_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("SOURCE_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("SOURCE_NAME") = value
    End Set
  End Property

  Public Property ACTIVE_IND() As String
    Get
      Return WELL_VERSION.Rows(0)("ACTIVE_IND").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("ACTIVE_IND") = value
      WELL_LICENSE.Rows(0)("ACTIVE_IND") = value
    End Set
  End Property

  Public Property IPL_UWI_LOCAL() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_UWI_LOCAL").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_UWI_LOCAL") = value
    End Set
  End Property

  Public Property COUNTRY() As String
    Get
      Return WELL_VERSION.Rows(0)("COUNTRY").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("COUNTRY") = value
    End Set
  End Property

  Public Property COUNTRY_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("COUNTRY_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("COUNTRY_NAME") = value
    End Set
  End Property

  Public Property WELL_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("WELL_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("WELL_NAME") = value
    End Set
  End Property

  Public Property PLOT_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("PLOT_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("PLOT_NAME") = value
    End Set
  End Property

  Public Property IPL_OFFSHORE_IND() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_OFFSHORE_IND").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_OFFSHORE_IND") = value
    End Set
  End Property

  Public Property PROFILE_TYPE() As String
    Get
      Return WELL_VERSION.Rows(0)("PROFILE_TYPE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("PROFILE_TYPE") = value
    End Set
  End Property

  Public Property PROFILE_TYPE_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("PROFILE_TYPE_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("PROFILE_TYPE_NAME") = value
    End Set
  End Property

  Public Property CURRENT_STATUS() As String
    Get
      Return WELL_VERSION.Rows(0)("CURRENT_STATUS").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("CURRENT_STATUS") = value
    End Set
  End Property

  Public Property CURRENT_STATUS_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("CURRENT_STATUS_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("CURRENT_STATUS_NAME") = value
    End Set
  End Property

  Public Property WV_OPERATOR() As String
    Get
      Return WELL_VERSION.Rows(0)("OPERATOR").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("OPERATOR") = value
    End Set
  End Property

  Public Property WV_OPERATOR_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("OPERATOR_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("OPERATOR_NAME") = value
    End Set
  End Property
  Public Property IPL_LICENSEE() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_LICENSEE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_LICENSEE") = value
      WELL_LICENSE.Rows(0)("LICENSEE") = value
    End Set
  End Property

  Public Property IPL_LICENSEE_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_LICENSEE_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_LICENSEE_NAME") = value
    End Set
  End Property

  Public Property GROUND_ELEV() As String
    Get
      'Return WELL_VERSION.Rows(0)("GROUND_ELEV").ToString()
      If WELL_VERSION.Rows(0)("GROUND_ELEV") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("GROUND_ELEV"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("GROUND_ELEV") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("GROUND_ELEV") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property GROUND_ELEV_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("GROUND_ELEV_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("GROUND_ELEV_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_GROUND_ELEV_CUOM") = value
    End Set
  End Property

  Public Property KB_ELEV() As String
    Get
      'Return WELL_VERSION.Rows(0)("KB_ELEV").ToString()
      If WELL_VERSION.Rows(0)("KB_ELEV") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("KB_ELEV"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("KB_ELEV") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("KB_ELEV") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property KB_ELEV_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("KB_ELEV_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("KB_ELEV_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_KB_ELEV_CUOM") = value
    End Set
  End Property

  Public Property ROTARY_TABLE_ELEV() As String
    Get
      'Return WELL_VERSION.Rows(0)("ROTARY_TABLE_ELEV").ToString()
      If WELL_VERSION.Rows(0)("ROTARY_TABLE_ELEV") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("ROTARY_TABLE_ELEV"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("ROTARY_TABLE_ELEV") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("ROTARY_TABLE_ELEV") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property DERRICK_FLOOR_ELEV() As String
    Get
      'Return WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV").ToString()
      If WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property DERRICK_FLOOR_ELEV_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("DERRICK_FLOOR_ELEV_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_DERRICK_FLOOR_ELEV_CUOM") = value
    End Set
  End Property

  Public Property WATER_DEPTH() As String
    Get
      'Return WELL_VERSION.Rows(0)("WATER_DEPTH").ToString()
      If WELL_VERSION.Rows(0)("WATER_DEPTH") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("WATER_DEPTH"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("WATER_DEPTH") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("WATER_DEPTH") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property WATER_DEPTH_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("WATER_DEPTH_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("WATER_DEPTH_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_WATER_DEPTH_CUOM") = value
    End Set
  End Property

  Public Property CASING_FLANGE_ELEV() As String
    Get
      'Return WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV").ToString()
      If WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property CASING_FLANGE_ELEV_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("CASING_FLANGE_ELEV_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_CASING_FLANGE_ELEV_CUOM") = value
    End Set
  End Property

  Public Property DRILL_TD() As String
    Get
      'Return WELL_VERSION.Rows(0)("DRILL_TD").ToString()
      If WELL_VERSION.Rows(0)("DRILL_TD") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("DRILL_TD"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("DRILL_TD") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("DRILL_TD") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property DRILL_TD_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("DRILL_TD_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("DRILL_TD_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_DRILL_TD_CUOM") = value
    End Set
  End Property

  Public Property LICENSE_NUM() As String
    Get
      Return WELL_LICENSE.Rows(0)("LICENSE_NUM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_LICENSE.Rows(0)("LICENSE_NUM") = value
    End Set
  End Property

  Public Property RIG_NAME() As String
    Get
      Return WELL_LICENSE.Rows(0)("RIG_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_LICENSE.Rows(0)("RIG_NAME") = value
    End Set
  End Property

  Public Property RIG_TYPE_CODE() As String
    Get
      Return WELL_LICENSE.Rows(0)("RIG_TYPE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_LICENSE.Rows(0)("RIG_TYPE") = value
    End Set
  End Property

  Public Property RIG_TYPE_NAME() As String
    Get
      Return WELL_LICENSE.Rows(0)("RIG_TYPE_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_LICENSE.Rows(0)("RIG_TYPE_NAME") = value
    End Set
  End Property

  Public Property LICENSE_DATE() As String
    Get
      If (String.IsNullOrEmpty(WELL_LICENSE.Rows(0)("LICENSE_DATE").ToString())) Then
        Return WELL_LICENSE.Rows(0)("LICENSE_DATE").ToString()
      Else
        Dim dt As Date = WELL_LICENSE.Rows(0)("LICENSE_DATE")
        Return String.Format("{0:00}/{1:00}/{2}", dt.Day, dt.Month, dt.Year)
      End If
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_LICENSE.Rows(0)("LICENSE_DATE") = System.DBNull.Value
      Else
        WELL_LICENSE.Rows(0)("LICENSE_DATE") = Date.Parse(value, New Globalization.CultureInfo("en-GB"))
      End If
    End Set
  End Property

  Public Property RIG_RELEASE_DATE() As String
    Get
      If (String.IsNullOrEmpty(WELL_VERSION.Rows(0)("RIG_RELEASE_DATE").ToString())) Then
        Return WELL_VERSION.Rows(0)("RIG_RELEASE_DATE").ToString()
      Else
        Dim dt As Date = WELL_VERSION.Rows(0)("RIG_RELEASE_DATE")
        Return String.Format("{0:00}/{1:00}/{2}", dt.Day, dt.Month, dt.Year)
      End If
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("RIG_RELEASE_DATE") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("RIG_RELEASE_DATE") = Date.Parse(value, New Globalization.CultureInfo("en-GB"))
      End If
    End Set
  End Property

  Public Property SPUD_DATE() As String
    Get
      If (String.IsNullOrEmpty(WELL_VERSION.Rows(0)("SPUD_DATE").ToString())) Then
        Return WELL_VERSION.Rows(0)("SPUD_DATE").ToString()
      Else
        Dim dt As Date = WELL_VERSION.Rows(0)("SPUD_DATE")
        Return String.Format("{0:00}/{1:00}/{2}", dt.Day, dt.Month, dt.Year)
      End If
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("SPUD_DATE") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("SPUD_DATE") = Date.Parse(value, New Globalization.CultureInfo("en-GB"))
      End If
    End Set
  End Property

  Public Property FINAL_DRILL_DATE() As String
    Get
      If (String.IsNullOrEmpty(WELL_VERSION.Rows(0)("FINAL_DRILL_DATE").ToString())) Then
        Return WELL_VERSION.Rows(0)("FINAL_DRILL_DATE").ToString()
      Else
        Dim dt As Date = WELL_VERSION.Rows(0)("FINAL_DRILL_DATE")
        Return String.Format("{0:00}/{1:00}/{2}", dt.Day, dt.Month, dt.Year)
      End If
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("FINAL_DRILL_DATE") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("FINAL_DRILL_DATE") = Date.Parse(value, New Globalization.CultureInfo("en-GB"))
      End If
    End Set
  End Property

  Public Property IPL_BASIN() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_BASIN").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_BASIN") = value
    End Set
  End Property

  Public Property IPL_BASIN_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_BASIN_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_BASIN_NAME") = value
    End Set
  End Property

  Public Property IPL_AREA() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_AREA").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_AREA") = value
    End Set
  End Property

  Public Property IPL_BLOCK() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_BLOCK").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_BLOCK") = value
    End Set
  End Property

  Public Property PROVINCE_STATE() As String
    Get
      Return WELL_VERSION.Rows(0)("PROVINCE_STATE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("PROVINCE_STATE") = value
    End Set
  End Property

  Public Property PROVINCE_STATE_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("PROVINCE_STATE_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("PROVINCE_STATE_NAME") = value
    End Set
  End Property

  Public Property COUNTY() As String
    Get
      Return WELL_VERSION.Rows(0)("COUNTY").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("COUNTY") = value
    End Set
  End Property

  Public Property COUNTY_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("COUNTY_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("COUNTY_NAME") = value
    End Set
  End Property

  Public Property DISTRICT() As String
    Get
      Return WELL_VERSION.Rows(0)("DISTRICT").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("DISTRICT") = value
    End Set
  End Property

  Public Property LEASE_NAME() As String
    Get
      Return WELL_VERSION.Rows(0)("LEASE_NAME").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("LEASE_NAME") = value
    End Set
  End Property

  Public Property ASSIGNED_FIELD() As String
    Get
      Return WELL_VERSION.Rows(0)("ASSIGNED_FIELD").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("ASSIGNED_FIELD") = value
    End Set
  End Property

  Public Property IPL_POOL() As String
    Get
      Return WELL_VERSION.Rows(0)("IPL_POOL").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("IPL_POOL") = value
    End Set
  End Property

  Public Property REMARK() As String
    Get
      Return WELL_VERSION.Rows(0)("REMARK").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("REMARK") = value
    End Set
  End Property

  Public Property OLDEST_STRAT_AGE() As String
    Get
      Return WELL_VERSION.Rows(0)("OLDEST_STRAT_AGE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("OLDEST_STRAT_AGE") = value
    End Set
  End Property

  Public Property OLDEST_STRAT_UNIT_ID() As String
    Get
      Return WELL_VERSION.Rows(0)("OLDEST_STRAT_UNIT_ID").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("OLDEST_STRAT_UNIT_ID") = value
    End Set
  End Property

  Public Property TD_STRAT_AGE() As String
    Get
      Return WELL_VERSION.Rows(0)("TD_STRAT_AGE").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("TD_STRAT_AGE") = value
    End Set
  End Property

  Public Property TD_STRAT_UNIT_ID() As String
    Get
      Return WELL_VERSION.Rows(0)("TD_STRAT_UNIT_ID").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("TD_STRAT_UNIT_ID") = value
    End Set
  End Property

  Public Property PLUGBACK_DEPTH() As String
    Get
      'Return WELL_VERSION.Rows(0)("PLUGBACK_DEPTH").ToString()
      If WELL_VERSION.Rows(0)("PLUGBACK_DEPTH") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("PLUGBACK_DEPTH"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("PLUGBACK_DEPTH") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("PLUGBACK_DEPTH") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property PLUGBACK_DEPTH_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("PLUGBACK_DEPTH_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("PLUGBACK_DEPTH_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_PLUGBACK_DEPTH_CUOM") = value
    End Set
  End Property

  Public Property IPL_PLUGBACK_TVD() As String
    Get
      'Return WELL_VERSION.Rows(0)("IPL_PLUGBACK_TVD").ToString()
      If WELL_VERSION.Rows(0)("IPL_PLUGBACK_TVD") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("IPL_PLUGBACK_TVD"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("IPL_PLUGBACK_TVD") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("IPL_PLUGBACK_TVD") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property MAX_TVD() As String
    Get
      'Return WELL_VERSION.Rows(0)("MAX_TVD").ToString()
      If WELL_VERSION.Rows(0)("MAX_TVD") Is System.DBNull.Value Then Return ""
      Return Format(WELL_VERSION.Rows(0)("MAX_TVD"), "#.#####")
    End Get
    Set(ByVal value As String)
      If String.IsNullOrEmpty(value) Then
        WELL_VERSION.Rows(0)("MAX_TVD") = System.DBNull.Value
      Else
        WELL_VERSION.Rows(0)("MAX_TVD") = Decimal.Parse(value)
      End If
    End Set
  End Property

  Public Property MAX_TVD_OUOM() As String
    Get
      Return WELL_VERSION.Rows(0)("MAX_TVD_OUOM").ToString()
    End Get
    Set(ByVal value As String)
      WELL_VERSION.Rows(0)("MAX_TVD_OUOM") = value
      WELL_VERSION.Rows(0)("WIM_MAX_TVD_CUOM") = value
    End Set
  End Property

  Private _USERID As String
  Public Property USERID() As String
    Get
      Return _USERID
    End Get
    Set(ByVal value As String)
      _USERID = value
      If WELL_VERSION.Rows(0)("WIM_ACTION_CD").ToString() <> "X" Then
        WELL_VERSION.Rows(0)("ROW_CHANGED_BY") = value
      End If

      If WELL_LICENSE.Rows(0)("WIM_ACTION_CD").ToString() <> "X" Then
        WELL_LICENSE.Rows(0)("ROW_CHANGED_BY") = value
      End If

      If WELL_VERSION.Rows(0)("WIM_ACTION_CD").ToString() = "C" Or _
          WELL_VERSION.Rows(0)("WIM_ACTION_CD").ToString() = "A" Then
        WELL_VERSION.Rows(0)("ROW_CREATED_BY") = value
      End If

      If WELL_LICENSE.Rows(0)("WIM_ACTION_CD").ToString() = "C" Or _
          WELL_LICENSE.Rows(0)("WIM_ACTION_CD").ToString() = "A" Then
        WELL_LICENSE.Rows(0)("ROW_CREATED_BY") = value
      End If
    End Set
  End Property

  Private _ACTION_DATE As Date
  Public Property ACTION_DATE() As Date
    Get
      Return _ACTION_DATE
    End Get
    Set(ByVal value As Date)
      _ACTION_DATE = value
      If WELL_VERSION.Rows(0)("WIM_ACTION_CD").ToString() <> "X" Then
        WELL_VERSION.Rows(0)("ROW_CHANGED_DATE") = value
      End If

      If WELL_LICENSE.Rows(0)("WIM_ACTION_CD").ToString() <> "X" Then
        WELL_LICENSE.Rows(0)("ROW_CHANGED_DATE") = value
      End If

      If WELL_VERSION.Rows(0)("WIM_ACTION_CD").ToString() = "C" Or _
         WELL_VERSION.Rows(0)("WIM_ACTION_CD").ToString() = "A" Then
        WELL_VERSION.Rows(0)("ROW_CREATED_DATE") = value
      End If

      If WELL_LICENSE.Rows(0)("WIM_ACTION_CD").ToString() = "C" Or _
         WELL_LICENSE.Rows(0)("WIM_ACTION_CD").ToString() = "A" Then
        WELL_LICENSE.Rows(0)("ROW_CREATED_DATE") = value
      End If
    End Set
  End Property

  Private _STATUS As Integer
  Public Property STATUS() As Integer
    Get
      Return _STATUS
    End Get
    Set(ByVal value As Integer)
      _STATUS = value
    End Set
  End Property

  Private _ERRORMSG As String
  Public Property ERRORMSG() As String
    Get
      Return _ERRORMSG
    End Get
    Set(ByVal value As String)
      _ERRORMSG = value
    End Set
  End Property

  Private _STATUS_CD As String
  Public Property STATUS_CD() As String
    Get
      Return _STATUS_CD
    End Get
    Set(ByVal value As String)
      _STATUS_CD = value
    End Set
  End Property

  Private _AUDIT_NO As Integer
  Public Property AUDIT_NO() As Integer
    Get
      Return _AUDIT_NO
    End Get
    Set(ByVal value As Integer)
      _AUDIT_NO = value
    End Set
  End Property

  Public WELL_VERSION As DataTable
  Public WELL_LICENSE As DataTable
  Public WELL_NODE_VERSION As DataTable

  Public Sub New(ByVal dsWellVersionDetails As DataSet)

    _IsWellVersionChanged = False
    _IsWellLicenseChanged = False
    _IsWellNodeVersionChanged = False

    WELL_VERSION = dsWellVersionDetails.Tables("WIM_STG_WELL_VERSION")
    WELL_LICENSE = dsWellVersionDetails.Tables("WIM_STG_WELL_LICENSE")
    WELL_NODE_VERSION = dsWellVersionDetails.Tables("WIM_STG_WELL_NODE_VERSION")

    WV_OPERATOR_NAME = BA_DisplayName(WV_OPERATOR_NAME, WV_OPERATOR)
    IPL_LICENSEE_NAME = BA_DisplayName(IPL_LICENSEE_NAME, IPL_LICENSEE)

  End Sub

  Public Shared Function BA_DisplayName(ByVal baName As String, _
                                        ByVal baCode As String) _
  As String
    Return IIf(String.IsNullOrEmpty(baName), _
               String.Empty, _
               baName + " {" + baCode + "}")
  End Function

End Class
