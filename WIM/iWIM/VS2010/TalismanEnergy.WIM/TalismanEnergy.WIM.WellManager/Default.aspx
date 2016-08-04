<%@ Page Language="vb"
         AutoEventWireup="false"
         MasterPageFile="~/WellManager.Master"
         CodeBehind="Default.aspx.vb"
         Inherits="TalismanEnergy.WIM.iWIM._Default" 
         title="iWIM - Home" %>
<%@ Register Assembly="ComponentArt.Web.UI"
             Namespace="ComponentArt.Web.UI"
             TagPrefix="ComponentArt" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="ContentBanner">
        <asp:Label ID="LblSearch"
                   CssClass="contentTitle"
                   runat="server"
                   Text="Welcome to iWIM"/>
        <asp:Label ID="lblMessage1"
                   CssClass="lblMessage1"
                   runat="server"
                   Text="" />
        <asp:Label ID="lblMessage2" 
                   CssClass="lblMessage2"
                   runat="server"
                   text="" />
    </div>
    <div id="DataGrid">
          <ComponentArt:DataGrid ID="DataGrid1" 
                                 Autotheming="True"
                                 CssClass="cart-datagrid"
                                 RunningMode="Client"
                                 PagerStyle="Numbered"
                                 PageSize="10"
                                 PagerInfoPosition="BottomLeft"
                                 PagerPosition="BottomRight"
                                 AllowMultipleSelect="true"
                                 runat="server" 
                                 AllowHorizontalScrolling="true"
                                 IndentCellWidth="7"
                                 AllowColumnResizing="true"
                                 FillContainer="True">
            <ClientEvents>
              <ItemBeforeSelect EventHandler="DataGrid1_onItemBeforeSelect" />
              <ItemSelect EventHandler="DataGrid1_onItemSelect" />
              <ItemUnSelect EventHandler="DataGrid1_onItemUnSelect" />
              <ColumnResize EventHandler="DataGrid1_onColumnResize" />
              <RenderComplete EventHandler="DataGrid1_onRenderComplete" />
            </ClientEvents>
            <Levels>
              <ComponentArt:GridLevel
                ShowSelectorCells="true"
                AllowReordering="false" 
                DataCellCssClass="cart-datagrid-cell-1"
                DataMember="Well"
                DataKeyField="UWI">
                <Columns>
                  <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="85" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="IPL_UWI_LOCAL" HeadingText="UWI" Width="120" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="SOURCE" Visible="false" />
                  <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="120" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="90" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="130" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="PLOT_NAME" HeadingText="Plot Name" Width="70" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="70" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date&lt;br&gt;(D/M/Y)" Width="70" Align="Center" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="RIG_RELEASE_DATE" HeadingText="Rig Release Date&lt;br&gt;(D/M/Y)" Width="70" Align="Center" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="GROUND_ELEV" HeadingText="Grd Elev" Width="60" Align="Right" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="KB_ELEV" HeadingText="KB Elev" Width="60" Align="Right" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill&lt;br&gt;Depth" Width="60" Align="Right" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface&lt;br&gt;Latitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd" DataCellClientTemplateId="SrfLatTemplate"/>
                  <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface&lt;br&gt;Longitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd" DataCellClientTemplateId="SrfLongTemplate"/>
                  <ComponentArt:GridColumn DataField="SURFACE_DATUM"  HeadingText="Surface&lt;br&gt;Geo Datum" Width="36" HeadingTextCssClass="grp-hd" />
                  <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole&lt;br&gt;Latitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd" DataCellClientTemplateId="BtmLatTemplate"/>
                  <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole&lt;br&gt;Longitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd" DataCellClientTemplateId="BtmLongTemplate"/>
                  <ComponentArt:GridColumn DataField="BOTTOM_HOLE_DATUM"  HeadingText="Bottom Hole&lt;br&gt;Geo Datum" Width="36" HeadingTextCssClass="grp-hd" />
                  <ComponentArt:GridColumn DataField="LICENSE_NUM" HeadingText="License&lt;br&gt;Number" Width="60" HeadingTextCssClass="grp-hd"/>
                  <ComponentArt:GridColumn DataField="ROW_CHANGED" HeadingText="Last&lt;br&gt;Changed" Width="115" HeadingTextCssClass="grp-hd"/>
                </Columns>            
              </ComponentArt:GridLevel>
              <ComponentArt:GridLevel
                ShowSelectorCells="true"
                DataMember="Source"
                DataKeyField="ID"  
                ShowHeadingCells="false">
                <Columns>
                  <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="85"/>
                  <ComponentArt:GridColumn DataField="IPL_UWI_LOCAL" HeadingText="UWI" Width="120"/>
                  <ComponentArt:GridColumn DataField="SOURCE" Visible="false" />
                  <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="120"/>
                  <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="90"/>
                  <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="130"/>
                  <ComponentArt:GridColumn DataField="PLOT_NAME" HeadingText="Plot Name" Width="70"/>
                  <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="70"/>
                  <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date &lt;br&gt; (dd/mm/yyyy)" Width="70" Align="Center"/>
                  <ComponentArt:GridColumn DataField="RIG_RELEASE_DATE" HeadingText="Rig Release Date &lt;br&gt; (dd/mm/yyyy)" Width="70" Align="Center"/>
                  <ComponentArt:GridColumn DataField="GROUND_ELEV" HeadingText="GRD Elev" Width="60" Align="Right"/>
                  <ComponentArt:GridColumn DataField="KB_ELEV" HeadingText="KB Elev" Width="60" Align="Right"/>
                  <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill &lt;br&gt; Depth" Width="60" Align="Right"/>
                  <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface &lt;br&gt; Latitude" Width="75" Align="Right" DataCellClientTemplateId="SrfLatTemplate"/>
                  <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface &lt;br&gt; Longitude" Width="75" Align="Right" DataCellClientTemplateId="SrfLongTemplate"/>
                  <ComponentArt:GridColumn DataField="SURFACE_DATUM"  HeadingText="Surface &lt;br&gt; Geo Datum" Width="36" HeadingTextCssClass="grp-hd" DataCellClientTemplateId="SrfDatumTemplate"/>
                  <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole &lt;br&gt; Latitude" Width="75" Align="Right" DataCellClientTemplateId="BtmLatTemplate"/>
                  <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole &lt;br&gt; Longitude" Width="75" Align="Right" DataCellClientTemplateId="BtmLongTemplate"/>
                  <ComponentArt:GridColumn DataField="BOTTOM_HOLE_DATUM"  HeadingText="Bottom Hole &lt;br&gt; Geo Datum" Width="36" HeadingTextCssClass="grp-hd" DataCellClientTemplateId="BtmDatumTemplate"/>
                  <ComponentArt:GridColumn DataField="LICENSE_NUM" HeadingText="License &lt;br&gt; Number" Width="60"/>
                  <ComponentArt:GridColumn DataField="ROW_CHANGED" HeadingText="Last&lt;br&gt;Changed" Width="115" DataCellCssClass="cart-datagrid-cell-small-2"/>
                  <ComponentArt:GridColumn DataField="ID"  HeadingText="ID" Width="80"  Visible="false"/>
                  <ComponentArt:GridColumn DataField="ACTIVE_IND" Visible="false" />
                </Columns>
                <ConditionalFormats>
                  <ComponentArt:GridConditionalFormat ClientFilter="DataItem.GetMember('ACTIVE_IND').Value != 'Y'"
                                                      RowCssClass="deactivatedRow"
                                                      HoverRowCssClass="deactivatedHoverRow"
                                                      SelectedRowCssClass="deactivatedSelectedRow"
                                                      SelectedHoverRowCssClass="deactivatedSelectedHoverRow"
                                                       />
                </ConditionalFormats>
              </ComponentArt:GridLevel>
            </Levels>
            <ClientTemplates>
              <ComponentArt:ClientTemplate Id="SrfLatTemplate" runat="server" >
                ## setTooltip(DataItem.GetMember('SURFACE_LATITUDE').Value,
                              'SURFACE',
                              DataItem.GetMember('SURFACE_LATITUDE').Value,
                              DataItem.GetMember('SURFACE_LONGITUDE').Value,
                              DataItem.GetMember('SURFACE_DATUM').Value) ##
              </ComponentArt:ClientTemplate>
              <ComponentArt:ClientTemplate Id="SrfLongTemplate" runat="server" >
                ## setTooltip(DataItem.GetMember('SURFACE_LONGITUDE').Value,
                              'SURFACE',
                              DataItem.GetMember('SURFACE_LATITUDE').Value,
                              DataItem.GetMember('SURFACE_LONGITUDE').Value,
                              DataItem.GetMember('SURFACE_DATUM').Value) ##
              </ComponentArt:ClientTemplate>
              <ComponentArt:ClientTemplate Id="SrfDatumTemplate" runat="server" >
                ## setTooltip(DataItem.GetMember('SURFACE_DATUM').Value,
                              'SURFACE',
                              DataItem.GetMember('SURFACE_LATITUDE').Value,
                              DataItem.GetMember('SURFACE_LONGITUDE').Value,
                              DataItem.GetMember('SURFACE_DATUM').Value) ##
              </ComponentArt:ClientTemplate>
              <ComponentArt:ClientTemplate Id="BtmLatTemplate" runat="server" >
                ## setTooltip(DataItem.GetMember('BOTTOM_HOLE_LATITUDE').Value,
                              'BOTTOM HOLE',
                              DataItem.GetMember('BOTTOM_HOLE_LATITUDE').Value,
                              DataItem.GetMember('BOTTOM_HOLE_LONGITUDE').Value,
                              DataItem.GetMember('BOTTOM_HOLE_DATUM').Value) ##
              </ComponentArt:ClientTemplate>
              <ComponentArt:ClientTemplate Id="BtmLongTemplate" runat="server" >
                ## setTooltip(DataItem.GetMember('BOTTOM_HOLE_LONGITUDE').Value,
                              'BOTTOM HOLE',
                              DataItem.GetMember('BOTTOM_HOLE_LATITUDE').Value,
                              DataItem.GetMember('BOTTOM_HOLE_LONGITUDE').Value,
                              DataItem.GetMember('BOTTOM_HOLE_DATUM').Value) ##
              </ComponentArt:ClientTemplate>
              <ComponentArt:ClientTemplate Id="BtmDatumTemplate" runat="server" >
                ## setTooltip(DataItem.GetMember('BOTTOM_HOLE_DATUM').Value,
                              'BOTTOM HOLE',
                              DataItem.GetMember('BOTTOM_HOLE_LATITUDE').Value,
                              DataItem.GetMember('BOTTOM_HOLE_LONGITUDE').Value,
                              DataItem.GetMember('BOTTOM_HOLE_DATUM').Value) ##
              </ComponentArt:ClientTemplate>
            </ClientTemplates>
          </ComponentArt:DataGrid>
    </div>
    <ComponentArt:Dialog ID="dlgFind"
                         ModalMaskImage="images/alpha.png"
                         Modal="true"
                         RenderOverWindowedObjects="true"
                         CssClass="dlg"
                         HeaderCssClass="dlgHeader"
                         ContentCssClass="dlgContent"
                         FooterCssClass="dlgFooter"
                         AllowDrag="true"
                         Alignment="MiddleCentre"
                         runat="server"
                         Height="151"
                         Width="450">
        <Header>
            <div class="ttlt">
                <div class="ttlt-l">
                </div>
                <div class="ttlt-m" onmousedown="dlgFind.StartDrag(event);">
                    <a class="close" onclick="dlgFind.close();this.blur();return false;"></a><span>Find a Well</span>
                </div>
                <div class="ttlt-r">
                </div>
            </div>
            <div class="ttlb">
                <div class="ttlb-l">
                    <span></span>
                </div>
                <div class="ttlb-m">
                    <span></span>
                </div>
                <div class="ttlb-r">
                    <span></span>
                </div>
            </div>
        </Header>
        <Content>
            <div class="con-l">
            </div>
            <div class="con-m">
                <p>Find a well to be added to the Home page.<br />
                   Select a type of identifier and its value that will uniquely specify the well.</p>
                <table>
                    <tr>
                        <td>
                            <asp:DropDownList ID="ddlAliasType" runat="server">
                                <asp:ListItem Selected="True" Value="TLM_ID">Talisman ID</asp:ListItem>
                                <asp:ListItem Value="PLOT_NAME">Plot Name</asp:ListItem>
                                <asp:ListItem Value="WELL_NAME">Well Name</asp:ListItem>
                                <asp:ListItem Value="WELL_NUM">Well Number</asp:ListItem>
                                <asp:ListItem Value="UWI">UWI</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                        <td>=</td>
                        <td>
                            <asp:TextBox id="txtValue" runat="server" onkeypress="return findOnEnter();"/>
                        </td>
                    </tr>
                </table>
                <ComponentArt:CallBack ID="cbckFind" Debug="false" runat="server">
                    <Content>
                    </Content>
                </ComponentArt:CallBack>
            </div>
            <div class="con-r">
            </div>
        </Content>
        <Footer>
            <div class="ftr-l">
            </div>
            <div class="ftr-m">
                <a onclick="findWellByAlias();" 
                    class="btn"><span>Find</span></a>
            </div>
            <div class="ftr-r">
            </div>
        </Footer>
    </ComponentArt:Dialog>
    
    <ComponentArt:CallBack ID="cbckRemove" Debug="false" runat="server">
        <Content>
        </Content>
    </ComponentArt:CallBack>
    
    <asp:Label ID="lblFindError" Visible="false" runat="server" CssClass="findErr"/>
    
    <div id="GridRowsControlsBar">
      <input id="btnAddRows"    runat="server" type="button" value="+" class="rowsControl" onclick="return ShowFindDialog();"/>                        
      <input id="btnRemoveRows" runat="server" type="button" value="–" class="rowsControl is-disabled" onclick="return RemoveRows();" disabled="disabled"  /> 
    </div>
    <div id="ActionButtonBar">
      <input id="btnAddVersion" runat="server" type="button" disabled="disabled" value="Add Version" class="actionButton" onclick="AddVersion();"/>                        
      <input id="btnViewVersion" runat="server" type="button" disabled="disabled" value="View Version" class="actionButton" onclick="ViewVersion(DataGrid1.GetSelectedItems()[0]);"/>
      <input id="btnEditVersion" runat="server" type="button" disabled="disabled" value="Edit Version" class="actionButton" onclick="EditVersion(DataGrid1.GetSelectedItems()[0]);"/>
      <input id="btnInactivateVersion" runat="server" type="button" disabled="disabled" value="Inactivate Version" class="actionButton" onclick="InactivateVersion(DataGrid1.GetSelectedItems()[0]);"/>
      <input id="btnReactivateVersion" runat="server" type="button" disabled="disabled" value="Reactivate Version" class="actionButton" onclick="ReactivateVersion(DataGrid1.GetSelectedItems()[0]);"/>
      <input id="btnDeleteVersion" runat="server" type="button" disabled="disabled" value="Delete Version" class="actionButton" onclick="DeleteVersion(DataGrid1.GetSelectedItems()[0]);"/>
      <input id="btnMoveVersion" runat="server" type="button" disabled="disabled" value="Move Versions" class="actionButton" onclick="MoveVersion();"/>
    </div>
    
        <script type="text/javascript">
            //<![CDATA[

          function escapeHtml(string) {
            return String(string).replace(/[&<>"'\/]/g, function (s) {
              return entityMap[s];
            });
          }
          function setTooltip(text, title, lat, long, datum) {
            var safeText = escapeHtml(escapeHtml(title + '\nLatitude: '+lat+'\nLongitude: '+long+'\nGeo. Datum: '+datum)).replace(/\n/g, '<br />');
            var span = '<span style="display:inline-block;width:100%;" ';
            span += 'onmouseover="tooltip.show(\'' + safeText + '\');" ';
            span += 'onmouseout="tooltip.hide();" >';
            span += text;
            span += '</span>';
            return span;
          }

          function ShowFindDialog() {
              ctl00_ContentPlaceHolder1_dlgFind.Show();
              document.getElementById("ctl00_ContentPlaceHolder1_txtValue").focus();
              return false;
            }

            function findOnEnter() {
              if (window.event && window.event.keyCode == 13)
              { return findWellByAlias() };
              return true;
            }
            
            function findWellByAlias() {
              var ddl = document.getElementById("ctl00_ContentPlaceHolder1_ddlAliasType");
              var idx = ddl.selectedIndex;
              var type = ddl.options[idx].value;
              var txtBox = document.getElementById("ctl00_ContentPlaceHolder1_txtValue");
              var value = txtBox.value;
              cbckFind.callback(type, value);
              return false;
            }
            
            function RefreshMe()
            { location.href = "/"; }
            
            function RemoveRows()
            {
                var items = DataGrid1.getSelectedItems()
                if (items && items.length > 0 && items[0].Level == 0)
                {
                    var tlmIds = "";
                    for ( var idx = 0; idx < items.length; idx++ )
                    {
                        var row = items[idx];
                        if ( tlmIds.length > 0 )
                        { tlmIds += ","; }
                        tlmIds += row.Cells[0].Text;
                    }
                    cbckRemove.callback(tlmIds);
                }
                return false;
            }

            function DataGrid1_onItemBeforeSelect(sender, eventArgs) {
                if (eventArgs) {
                    // If about to select a version, clear any current selection.
                    // This ensures a max of 1 version selected and never together with a well.
                    if (eventArgs.get_item().Level == 1) {
                        DataGrid1.unSelectAll();
                    }
                    // If about to select a well and currently a version is selected,
                    // clear any selection
                    if (eventArgs.get_item().Level == 0) {
                        var items = DataGrid1.getSelectedItems()
                        if (items) if (items.length >= 1)
                            if (items[0].Level == 1)
                                DataGrid1.unSelectAll();
                    }
                }
            }
            
            function DataGrid1_onItemSelect(sender, eventArgs) {
                if (eventArgs)
                {
                    // Why is this done repeatedly?
                    var addallowed = document.getElementById("ctl00_ContentPlaceHolder1_AddVersionsAllowed").value;
                    document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = ! (addallowed.length > 0);
                        
                    if (eventArgs.get_item().Level == 0)
                    {
                        // Selecting a(nother) well.
                        var wells = DataGrid1.getSelectedItems();
                        var nWells = 0;
                        if (wells)
                        { nWells = wells.length; }
                        
                        // Any previously selected versions caused the selection to be clesred in the preSelect
                        // Disable buttons requiring a selected version
                        document.getElementById("ctl00_ContentPlaceHolder1_btnDeleteVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnViewVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnEditVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnInactivateVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnReactivateVersion").disabled = true;

                        // Enable Move Versions if allowed for this user
                        var moveallowed = document.getElementById("ctl00_ContentPlaceHolder1_MoveVersionsAllowed").value;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnMoveVersion").disabled =
                          ! (moveallowed.length > 0 && nWells > 0 && nWells < 3 );
                        document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = (nWells != 1);
                        
                        if (nWells < 1)
                        { $("#ctl00_ContentPlaceHolder1_btnRemoveRows").attr('disabled','disabled').addClass("is-disabled"); }
                        else
                        { $("#ctl00_ContentPlaceHolder1_btnRemoveRows").removeAttr('disabled').removeClass("is-disabled"); }
                    }
                    if (eventArgs.get_item().Level == 1)
                    {
                        // Selecting a version.
                        
                        // Any previously selected wells or versions caused the selection to be clesred in the preSelect
                        document.getElementById("ctl00_ContentPlaceHolder1_btnMoveVersion").disabled = true;

                        var source = DataGrid1.GetSelectedItems()[0].getMember('SOURCE').Value;
                        var active = (DataGrid1.GetSelectedItems()[0].getMember('ACTIVE_IND').Value == 'Y');

                        var deleteallowed = document.getElementById("ctl00_ContentPlaceHolder1_DeleteVersionsAllowed").value;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnDeleteVersion").disabled = ! (deleteallowed.match(source));

                        document.getElementById("ctl00_ContentPlaceHolder1_btnViewVersion").disabled = false;
                        
                        var editallowed = document.getElementById("ctl00_ContentPlaceHolder1_EditVersionsAllowed").value;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnEditVersion").disabled = ! (editallowed.match(source) && active);
                        
                        var inactivateallowed = document.getElementById("ctl00_ContentPlaceHolder1_InactivateVersionsAllowed").value;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnInactivateVersion").disabled = ! (inactivateallowed.match(source) && active);

                        var reactivateallowed = document.getElementById("ctl00_ContentPlaceHolder1_ReactivateVersionsAllowed").value;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnReactivateVersion").disabled = ! (reactivateallowed.match(source) && !active);

                        $("#ctl00_ContentPlaceHolder1_btnRemoveRows").attr('disabled', 'disabled').addClass("is-disabled");
                    }
                }
            }
            
            function DataGrid1_onItemUnSelect(sender, eventArgs) {
                if (eventArgs)
                {
                    if (eventArgs.get_item().Level == 0)
                    {
                        // UnSelecting a well.
                        
                        var wells = DataGrid1.getSelectedItems();
                        var nWells = 0;
                        if (wells)
                        { nWells = wells.length; }
                        var moveallowed = document.getElementById("ctl00_ContentPlaceHolder1_MoveVersionsAllowed").value;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnMoveVersion").disabled =
                          (moveallowed.length < 1 || nWells < 1 || nWells > 2 );
                        document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = (nWells != 1);
                        if (nWells < 1)
                        { $("#ctl00_ContentPlaceHolder1_btnRemoveRows").attr('disabled','disabled').addClass("is-disabled"); }
                        else
                        { $("#ctl00_ContentPlaceHolder1_btnRemoveRows").removeAttr('disabled').removeClass("is-disabled"); }
                    }
                    if (eventArgs.get_item().Level == 1)
                    {
                        // UnSelecting a (actually, the) version.
                        
                        document.getElementById("ctl00_ContentPlaceHolder1_btnDeleteVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnViewVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnEditVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnInactivateVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnReactivateVersion").disabled = true;
                        $("#ctl00_ContentPlaceHolder1_btnRemoveRows").attr('disabled', 'disabled').addClass("is-disabled");
                    }
                }
            }

            function DataGrid1_onRenderComplete(sender, eventArgs){
                if ((eventArgs)&&(sender.Levels[1].Table)) {
                    for (i=0; i<sender.Levels[0].Table.Columns.length; i++){
                        sender.Levels[1].Table.Columns[i].set_width(sender.Levels[0].Table.Columns[i].get_width());
                    }
                }
                //$("#ctl00_ContentPlaceHolder1_btnRemoveRows").attr('disabled','disabled').addClass("is-disabled");
            }
            
            function DataGrid1_onColumnResize(sender, eventArgs){
                if ((eventArgs)&&(sender.Levels[1].Table)) {
                    var colNumber = eventArgs.get_column().ColumnNumber;
                    sender.Levels[1].Table.Columns[colNumber].set_width(sender.Levels[0].Table.Columns[colNumber].get_width() + eventArgs.get_change());
                    sender.Levels[0].Table.Columns[colNumber].set_width(sender.Levels[0].Table.Columns[colNumber].get_width() + eventArgs.get_change());
                    
                    eventArgs.set_cancel(true);
                    sender.render();
                }
            }

            function ViewVersion(well) {
              if (well) {
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";

                var key = well.Data[0] + "," + well.Data[2];
                location.href = "ViewWell.aspx" + "?Wellkey=" + escape(key);
              }
            }
            
            function EditVersion(well) 
            {
                if (well) 
                {
                    document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                    document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";

                    var key = well.Data[0] + "," + well.Data[2];
                    location.href = "EditWell.aspx" + "?Wellkey=" + escape(key);
                }
            }

            function DeleteVersion(well) 
            {
                if (well) 
                {
                    document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                    document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";

                    if (confirm('Well [' + well.Data[0] + '] Version [' + well.Data[2] + '] will be permanently DELETED from the database.\n'))
                    {
                        var key = well.Data[0] + "," + well.Data[2];
                        location.href = "Default.aspx" + "?Action=D&Wellkey=" + escape(key);
                        return true;
                    }
                    else
                    {
                        DataGrid1.unSelectAll();
                        return false;
                    }
                }
            }

            function InactivateVersion(well) 
            {
                if (well)
                {
                    document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                    document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";

                    if (confirm('Well [' + well.Data[0] + '] Version [' + well.Data[2] + '] will be INACTIVATED and no longer contribute to the COMPOSITE well definition.\n'))
                    {
                        var key = well.Data[0] + "," + well.Data[2];
                        location.href = "Default.aspx" + "?Action=I&Wellkey=" + escape(key);
                        return true;
                    }
                    else
                    {
                        DataGrid1.unSelectAll();
                        return false;
                    }
                }
            }

            function ReactivateVersion(well) {
              if (well) {
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";

                if (confirm('Well [' + well.Data[0] + '] Version [' + well.Data[2] + '] will be REACTIVATED and contribute to the COMPOSITE well definition.\n')) {
                  var key = well.Data[0] + "," + well.Data[2];
                  location.href = "Default.aspx" + "?Action=R&Wellkey=" + escape(key);
                  return true;
                }
                else {
                  DataGrid1.unSelectAll();
                  return false;
                }
              }
            }

            function AddVersion() 
            {
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";
                
                if (DataGrid1.GetSelectedItems().length == 0)
                {
                    alert("Please make a selection before proceeding.");
                }
                else
                {
                    if (DataGrid1.GetSelectedItems().length > 1)
                    {
                        alert ("Please select a single COMPOSITE well to Add version to.");
                        DataGrid1.unSelectAll();
                    }
                    else
                    {
                        var well = DataGrid1.GetSelectedItems()[0];
                        var key = well.Data[0] + "," ;
                        location.href = "AddVersion.aspx" + "?Wellkey=" + escape(key);
                   }
                }
            }
           
            function MoveVersion() 
            {
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage1").innerText = "";
                document.getElementById("ctl00_ContentPlaceHolder1_lblMessage2").innerText = "";

                if (DataGrid1.GetSelectedItems().length == 0)
                {
                    alert("Please select 1 or 2 COMPOSITE wells before proceeding.");
                }
                else
                {
                    if (DataGrid1.GetSelectedItems().length == 1)
                    {
                        if (DataGrid1.GetSelectedItems()[0].Level == 1)
                        {
                            alert("This action is valid on COMPOSITE wells only.  Please select appropriate COMPOSITE well.");
                        }
                        else
                        {
                            var wellItem = DataGrid1.GetSelectedItems()[0];
                            var key = wellItem.Data[0];
                        
                            location.href = "MoveVersion.aspx" + "?Wellkey1=&Wellkey2=" + escape(key);
                        }
                    }
                    else
                    {
                        var wellItem1 = DataGrid1.GetSelectedItems()[0];
                        var key1 = wellItem1.Data[0];
                        
                        var wellItem2 = DataGrid1.GetSelectedItems()[1];                 
                        var key2 = wellItem2.Data[0];
                        
                        location.href = "MoveVersion.aspx" + "?Wellkey1=" + escape(key1) + "&Wellkey2=" + escape(key2);
                    }
                }
            }
            
            //]]>
        </script>
    <asp:HiddenField ID="AddVersionsAllowed" runat="server"/>
    <asp:HiddenField ID="DeleteVersionsAllowed" runat="server"/>
    <asp:HiddenField ID="EditVersionsAllowed" runat="server"/>
    <asp:HiddenField ID="InactivateVersionsAllowed" runat="server"/>
    <asp:HiddenField ID="ReactivateVersionsAllowed" runat="server"/>
    <asp:HiddenField ID="MoveVersionsAllowed" runat="server"/>
</asp:Content>
