/*******************************************************************************

 Add more items from which to extract housekeeping counts

 History
  20150807  cdong   QC1713 report on records management orphans - add new checks
                    QC1686 report on wells with KB elevation zero or less

 Run from WIM schema

 *******************************************************************************/

----20150807  cdong   QC1686 report on wells with KB elevation zero or less
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('037'
            , 'Wells with KB Elevation of zero or less.  This is possible, but is atypical and unusual.'
            , 'wim_housekeeping: number of wells with kb elevation of zero or negative value'
            , NULL
            , 'logcount'
            , 'Y')
;

----20150807  cdong   QC1713 report on records management orphans - add new checks
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('038'
            , 'Records Management items where the associated well is no longer active and/or does not exist.'
            , 'wim_housekeeping: number of rm records without an active well'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('039'
            , 'Records Management items where the associated area is no longer active and/or does not exist.'
            , 'wim_housekeeping: number of rm records without an active area'
            , NULL
            , 'logcount'
            , 'Y')
;

