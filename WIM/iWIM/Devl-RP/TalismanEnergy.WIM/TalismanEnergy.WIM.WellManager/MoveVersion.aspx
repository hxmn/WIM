<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/WellManager.Master" CodeBehind="MoveVersion.aspx.vb" Inherits="TalismanEnergy.WIM.iWIM.MoveVersion" 
    title="iWIM - Move Versions" %>
<%@ Register Assembly="ComponentArt.Web.UI" Namespace="ComponentArt.Web.UI" TagPrefix="ComponentArt" %>

<asp:Content ID="Content1" 
    ContentPlaceHolderID="ContentPlaceHolder1" 
    runat="server">
    
<script type="text/javascript">
    //<![CDATA[

    function DataGrid_onItemExternalDrop(sender, eventArgs)
    {
        var items = [ eventArgs.get_item() ];
        MoveVersions(items, eventArgs.get_targetControl());
    }

    function MoveVersions(items, dstGrid)
    {
        var rowIDs = [];
        var idx;
        var wellNo;
        
        if ( dstGrid.get_id() == "ctl00_ContentPlaceHolder1_DataGrid1" )
        { wellNo = 1; }
        else if ( dstGrid.get_id() == "ctl00_ContentPlaceHolder1_DataGrid2" )
        { wellNo = 2; }
        else
        { return; }

        for ( idx in items )
        { rowIDs[idx] = items[idx].Key; }
        
        var uri = "MoveVersion.aspx?MoveTo="
                        + wellNo
                        + "&RowIDs="
                        + escape(rowIDs.join(","));
        location.href = uri;
    }

    function MoveAllDown()
    {
        if (DataGrid1.RecordCount < 1)
        {
            alert("No versions are available to be moved.");
            return;
        }
        DataGrid1.SelectAll();
        MoveSelectedDown();
    }

    function MoveSelectedDown()
    {
        var items = DataGrid1.getSelectedItems();
        if (items.length < 1)
        {
            alert("No versions are selected to be moved.");
            return;
        }
        MoveVersions(items,DataGrid2);
    }

    function MoveAllUp()
    {
        if (DataGrid2.RecordCount < 1)
        {
            alert("No versions are available to be moved.");
            return;
        }
        DataGrid2.SelectAll();
        MoveSelectedUp();
    }

    function MoveSelectedUp()
    {
        var items = DataGrid2.getSelectedItems();
        if (items.length < 1)
        {
            alert("No versions are selected to be moved.");
            return;
        }
        MoveVersions(items,DataGrid1);
    }

    function confirmAction()
    {
        if (DataGrid1.RecordCount == 0)
        {
            var i = 0;
            var well1 = "";
            
            for (i = 0; i < DataGrid2.RecordCount; i++)
            {
                if (DataGrid2.Table.Data[i][0] != DataGrid2.Table.Data[i][13])
                {
                    well1 = DataGrid2.Table.Data[i][13];
                }
            }
            
            if(confirm('Well ' + well1 + ' will no longer exist once all versions are moved.\n'))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        if (DataGrid2.RecordCount == 0)
        {
            var i = 0;
            var well2 = "";
            
            for (i = 0; i < DataGrid1.RecordCount; i++)
            {
                if (DataGrid1.Table.Data[i][0] != DataGrid1.Table.Data[i][13])
                {
                    well2 = DataGrid1.Table.Data[i][13];
                }
            }

            if(confirm('Well ' + well2 + ' will no longer exist once all versions are moved.\n'))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
        
    //]]>
    
</script>
    <div id="ContentBanner">
        <asp:Label ID="lblMoveVersion" 
                   runat="server"
                   CssClass="contentTitle"
                   Text="Move Versions">
        </asp:Label>
        <asp:Label ID="lblMessage" 
                   runat="server" 
                   CssClass="versionDetailError"
                   Text="">
        </asp:Label>
    </div>
    <div id="MovePanel">
        <asp:Panel ID="Panel2" runat="server" BorderWidth="0"  Width="99%" Style=" position: static; top: 5px; padding: 5px; " >
            <table style="width: 100%; border: 0; border-color: Black; ">
                <tr>
                    <td>
                        <asp:Label ID="lblWell1" runat="server" Text="" CssClass="moveWell1" />
                        <br />
                        <ComponentArt:DataGrid ID="DataGrid1" 
                            Style="left: 0px; position: static; top: 10px;" 
                            Autotheming="true"
                            CssClass="cart-datagrid"
                            RunningMode="Client"
                            AllowPaging="false" 
                            ShowFooter="false"
                            PagerStyle="Numbered"
                            AllowMultipleSelect="true"
                            ItemDraggingEnabled="true"
                            ExternalDropTargets="ctl00_ContentPlaceHolder1_DataGrid2"
                            runat="server" 
                            AllowHorizontalScrolling="true"
                            Width="95%"          
                            FillContainer="true">
                            <ClientEvents>
                                <ItemExternalDrop EventHandler="DataGrid_onItemExternalDrop" />
                            </ClientEvents>
                            <Levels>
                              <ComponentArt:GridLevel 
                                DataMember="Version"
                                DataKeyField="ID"
                                ShowSelectorCells="false"
                                ShowHeadingCells="true"
                                RowCssClass="does-not-exist-component-art-bug-workaround"
                                SelectedRowCssClass="does-not-exist-component-art-bug-workaround"
                                HoverRowCssClass="does-not-exist-component-art-bug-workaround">
                                <ConditionalFormats>
                                    <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value != DataItem.GetMember('ORIG_UWI').Value"
                                        RowCssClass="cart-datagrid-row-2"
                                        SelectedRowCssClass="cart-datagrid-row-selected-2"
                                        HoverRowCssClass="cart-datagrid-row-hover-2"/>
                                    <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value == DataItem.GetMember('ORIG_UWI').Value"
                                        RowCssClass="cart-datagrid-row-1"
                                        SelectedRowCssClass="cart-datagrid-row-selected-1"
                                        HoverRowCssClass="cart-datagrid-row-hover-1"/>
                                </ConditionalFormats> 
                                  <Columns>
                                    <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE" HeadingText="Source" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="60" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="45" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="115" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="85" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date&lt;br&gt;(D/M/Y)" Width="60" Align="Center" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill&lt;br&gt;Depth" Width="40" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface&lt;br&gt;Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface&lt;br&gt;Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole&lt;br&gt;Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole&lt;br&gt;Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="ID"  HeadingText="ID" Width="0"  Visible="false"/>                                    
                                    <ComponentArt:GridColumn DataField="ORIG_UWI"  HeadingText="ORIG_UWI" Width="0"  Visible="false"/>                                    
                                 </Columns>
                             </ComponentArt:GridLevel>
                            </Levels>
                        </ComponentArt:DataGrid>
                    </td>
                    <td style=" width: 5px">
                        <br />
                        <a href="javascript:MoveAllDown();"> 
                            <img src="images/arrow_down_all.gif"
                                 title="Move All Versions Down"
                                 alt="Move All Down"
                                 style="border:0; background-color: transparent; vertical-align:middle"
                                 width="30px"/>
                        </a>
                        <br />
                        <a href="javascript:MoveSelectedDown();"> 
                            <img src="images/arrow_down.gif"
                                 title="Move Selected Version(s) Down"
                                 alt="Move Selected Down"
                                 style="border:0; background-color: transparent; vertical-align:middle"
                                 width="16px"/>
                        </a>
                    </td>
                </tr>
            </table>
        </asp:Panel>
        <asp:Panel ID="Panel3" runat="server" BorderWidth="0"  Width="99%" Style=" position: static; top: 5px; padding: 5px; " >
            <table style="width: 100%; border: 0; border-color: Black;">
                <tr>
                    <td>
                        <asp:Label ID="lblWell2" runat="server" Text="" CssClass="moveWell2" />
                        <br />
                        <ComponentArt:DataGrid ID="DataGrid2"
                            Style="left: 0px; position: static; top: 10px;" 
                            Autotheming="true"
                            CssClass="cart-datagrid"
                            RunningMode="Client"
                            AllowPaging="false" 
                            ShowFooter="false"
                            AllowMultipleSelect="true"
                            ItemDraggingEnabled="true"
                            ExternalDropTargets="ctl00_ContentPlaceHolder1_DataGrid1"
                            runat="server" 
                            AllowHorizontalScrolling="true"
                            Width="95%"          
                            FillContainer="true">
                            <ClientEvents>
                              <ItemExternalDrop EventHandler="DataGrid_onItemExternalDrop" />
                            </ClientEvents>
                            <Levels>
                              <ComponentArt:GridLevel 
                                DataMember="Version"
                                DataKeyField="ID"
                                ShowSelectorCells="false"
                                ShowHeadingCells="true"
                                RowCssClass="does-not-exist-component-art-bug-workaround"
                                SelectedRowCssClass="does-not-exist-component-art-bug-workaround"
                                HoverRowCssClass="does-not-exist-component-art-bug-workaround">
                                <ConditionalFormats>
                                    <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value != DataItem.GetMember('ORIG_UWI').Value"
                                        RowCssClass="cart-datagrid-row-1"
                                        SelectedRowCssClass="cart-datagrid-row-selected-1"
                                        HoverRowCssClass="cart-datagrid-row-hover-1"/>
                                    <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value == DataItem.GetMember('ORIG_UWI').Value"
                                        RowCssClass="cart-datagrid-row-2"
                                        SelectedRowCssClass="cart-datagrid-row-selected-2"
                                        HoverRowCssClass="cart-datagrid-row-hover-2"/>
                                </ConditionalFormats> 
                                  <Columns>
                                    <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE" HeadingText="Source" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="60" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="45" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="115" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="85" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date&lt;br&gt; (D/M/Y)" Width="60" Align="Center" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill&lt;br&gt;Depth" Width="40" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface&lt;br&gt;Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface&lt;br&gt;Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole&lt;br&gt;Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole&lt;br&gt;Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="ID"  HeadingText="ID" Width="0"  Visible="false"/>                                    
                                    <ComponentArt:GridColumn DataField="ORIG_UWI"  HeadingText="ORIG_UWI" Width="0"  Visible="false"/>                                    
                                 </Columns>
                                </ComponentArt:GridLevel>
                            </Levels>
                        </ComponentArt:DataGrid>
                    </td>
                    <td style=" width: 5px">
                        <br />
                        <a href="javascript:MoveSelectedUp();"> 
                            <img src="images/arrow_up.gif"
                                 title="Move Selected Version(s) Up"
                                 alt="Move Selected Up"
                                 style="border:0; background-color: transparent; vertical-align:middle"
                                 width="16px"/>
                        </a>
                        <br />
                        <a href="javascript:MoveAllUp();"> 
                            <img src="images/arrow_up_all.gif"
                                 title="Move All Versions Up"
                                 alt="Move All Up"
                                 style="border:0; background-color: transparent; vertical-align:middle"
                                 width="30px"/>
                        </a>
                    </td>
                </tr>                
              </table>
            <div id="ActionButtonBar">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="actionButton" OnClientClick="javascript:return confirmAction();" OnClick="btnSave_Click"/>
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="actionButton"/>
                <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="actionButton"/>
            </div>
        </asp:Panel>        
    </div>
</asp:Content>
