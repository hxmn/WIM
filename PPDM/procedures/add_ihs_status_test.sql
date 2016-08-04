select *
from ppdm.r_well_status
where status = '24020000'
;

exec add_ihs_status(q'['24020000']', 'US')


delete
from ppdm.r_well_status
where status = '24020000'