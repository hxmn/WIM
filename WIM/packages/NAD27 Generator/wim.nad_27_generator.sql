create or replace package nad27_generator
is
    procedure fme_cleanup;
    procedure load_fme_converted(
        p_use_locator_to_convert varchar2 default 'N'
    );
    function get_ztis_lq_ref(p_location_qualifier  varchar2) return varchar2;
end nad27_generator;
/