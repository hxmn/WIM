<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/WellManager.Master" CodeBehind="MoveVersion.aspx.vb" Inherits="TalismanEnergy.WIM.iWIM.MoveVersion" 
    title="iWIM - Move Version(s)" %>
<%@ Register Assembly="ComponentArt.Web.UI" Namespace="ComponentArt.Web.UI" TagPrefix="ComponentArt" %>

<asp:Content ID="Content1" 
    ContentPlaceHolderID="ContentPlaceHolder1" 
    runat="server">
    
<script type="text/javascript">
    //<![CDATA[

    function DataGrid1_onItemSelect(sender, eventArgs)
    {
        if (eventArgs) {
            if (eventArgs.get_item().Level == 0) {
            }
        }
    }

    function DataGrid1_onItemBeforeSelect(sender, eventArgs) {
        if (eventArgs) {
            if (eventArgs.get_item().Level == 0) {
                var items = sender.getSelectedItems()
                if (items.length > 0)if (eventArgs.get_item().Key == items[0].Key)
                {
                    sender.unSelect(items[0]);
                    eventArgs.set_cancel(true);
                }
            }
        }
    }

    function DataGrid2_onItemSelect(sender, eventArgs)
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblMessage").innerText = "";
        
        if (eventArgs) {
            if (eventArgs.get_item().Level == 0) {
            }
        }
    }

    function DataGrid2_onItemBeforeSelect(sender, eventArgs) {
        if (eventArgs) {
            if (eventArgs.get_item().Level == 0) {
                var items = sender.getSelectedItems()
                if (items.length > 0)if (eventArgs.get_item().Key == items[0].Key)
                {
                    sender.unSelect(items[0]);
                    eventArgs.set_cancel(true);
                }
            }
        }
    }

    function MoveAllVersionDown()
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblMessage").innerText = "";
        
        var items = "";
        var errMsg = "";        
        var IDs = "";   
        var i = 0;
        var j = 0;     
        var well = "";
        
        if (DataGrid1.RecordCount > 0)
        {
            DataGrid1.SelectAll();
            items = DataGrid1.getSelectedItems();
        }
        else
        {
            alert("No version available for move.");
            return;
        }
                
        for (j = 0; j < items.length; j++)
        {
            var move = true;
            
            for (i = 0; i < DataGrid2.RecordCount; i++)
            {
                if (items[j].Data[1] == DataGrid2.Table.Data[i][1])
                {
                    DataGrid1.unSelect(items[j]);
                    move = false;
                }
            } 
            if (move)
            {
                //move version to well 2
                if (IDs == "")
                {
                    IDs = items[j].Key;
                }
                else
                {
                    IDs += "," + items[j].Key; 
                }
            }
            else
            {
                errMsg += " - " + DataGrid1.Table.Data[j][2] + "\n";
            }
        }            
        if (IDs != "") location.href = "MoveVersion.aspx" + "?Action=MOVEALLDOWN" + "&ID1=" + escape(IDs);
        
        if (!errMsg == "")
        {
            well = DataGrid2.Table.Data[0][0];
            window.alert("The following version(s) exist in " + well + " and will not be moved:\n\n" + errMsg + "\n" + "Please contact TIS Group for assistance.\n");
        }        
    }

    function MoveVersionDown()
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblMessage").innerText = "";

        var items = DataGrid1.getSelectedItems();
        var errMsg = ""; 
        var IDs = "";   
        var i = 0;
        var j = 0;     
        var well = "";
       
        if (items.length > 0)
        {           
            //Check if any of the version(s) to be moved exists in destination well.  If exists, do not allow move of duplicate version
            for (j = 0; j < items.length; j++)
            {
                var move = true;
                
                for (i = 0; i < DataGrid2.RecordCount; i++)
                {
                    if (items[j].Data[1] == DataGrid2.Table.Data[i][1])
                    {
                        DataGrid1.unSelect(items[j]);
                        move = false;
                    }
                }
                if (move)
                {
                    //move selected version to well 2
                    if (IDs == "")
                    {
                        IDs = items[j].Key;
                    }
                    else
                    {
                        IDs += "," + items[j].Key; 
                    }
                }
                else
                {
                    errMsg += " - " + items[j].Data[2] + "\n";
                }
            }            
            if (IDs != "") location.href = "MoveVersion.aspx" + "?Action=MOVEDOWN" + "&ID1=" + escape(IDs);
        }
        else
        {
            alert("Please select version(s) to move to Well 2.");
        }

        if (!errMsg == "")
        {
            well = DataGrid2.Table.Data[0][0];
            window.alert("The following version(s) exist in " + well + " and will not be moved.\n\n" + errMsg + "\n" + "Please contact TIS Group for assistance.\n");
        }                
    }

    function MoveVersionUp()
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblMessage").innerText = "";

        var items = DataGrid2.getSelectedItems();
        var errMsg = "";        
        var IDs = "";   
        var i = 0;
        var j = 0;     
        var well = "";
        
        if (items.length > 0)
        {
            //Check if any of the version(s) to be moved exists in destination well.  If exists, do not allow move of duplicate version
            for (j = 0; j < items.length; j++)
            {                   
                var move = true;
            
                for (i = 0; i < DataGrid1.RecordCount; i++)
                {
                    if (items[j].Data[1] == DataGrid1.Table.Data[i][1])
                    {
                        DataGrid2.unSelect(items[j]);
                        move = false;
                    }
                }
                if (move)
                {
                    if (IDs == "")
                    {
                        IDs = items[j].Key;
                    }                      
                    else
                    {
                        IDs += "," + items[j].Key;
                    }
                }
                else
                {
                    errMsg += " - " + items[j].Data[2] + "\n";
                }
            }
            if (IDs != "") location.href = "MoveVersion.aspx" + "?Action=MOVEUP" + "&ID2=" + escape(IDs);
        }
        else
        {
            alert("Please select version(s) to move to Well 1.");
        }
        
        if (!errMsg == "")
        {
            well = DataGrid1.Table.Data[0][0];
            window.alert("The following version(s) exist in " + well + " and will not be moved.\n\n" + errMsg + "\n" + "Please contact TIS Group for assistance.\n");
        }                
    }

    function MoveAllVersionUp()
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblMessage").innerText = "";

        var items = "";
        var errMsg = "";
        var IDs = "";
        var i = 0;
        var j = 0;
        var well = "";
        
        if (DataGrid2.RecordCount > 0)
        {
            DataGrid2.SelectAll();
            items = DataGrid2.getSelectedItems();
        }
        else
        {
            alert("No version available for move.");
            return;
        }
        
        for (j = 0; j < items.length; j++)
        {
            move = true;
            
            for (i = 0; i < DataGrid1.RecordCount; i++)
            {
                if (items[j].Data[1] == DataGrid1.Table.Data[i][1])
                {
                    DataGrid2.unSelect(items[j]);
                    move = false;
                }
            }
            if (move)
            {
                if (IDs == "")
                {
                    IDs = items[j].Key;
                }
                else
                {
                    IDs += "," + items[j].Key; 
                }
            }
            else
            {
                errMsg += " - " + DataGrid2.Table.Data[j][2] + "\n";
            }
        }            
        if (IDs != "") location.href = "MoveVersion.aspx" + "?Action=MOVEALLUP" + "&ID2=" + escape(IDs);
        
        if (!errMsg == "")
        {
            well = DataGrid1.Table.Data[0][0];
            window.alert("The following version(s) exist in " + well + " and will not be moved.\n\n" + errMsg + "\n" + "Please contact TIS Group for assistance.\n");
        }        
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
    <asp:Label ID="lblMoveVersion" 
        runat="server" 
        Style="left: 8px; position: absolute; top: 20px; z-index: 100;" 
        Text="Move Version(s)" 
        Height="45px"  
        Width="954px" 
        Font-Bold="True" 
        Font-Names="Verdana"
        Font-Size="Small">
    </asp:Label>
    <asp:Label ID="lblMessage" 
        runat="server" 
        Style="left: 8px; position: absolute; top: 20px; z-index: 100;" 
        Height="45px" 
        Width="954px" 
        Font-Bold="true"
        Font-Names="Verdana" 
        Font-Size="Small">
    </asp:Label>
    <asp:Panel ID="Panel1" runat="server"  BorderWidth="0" Width="99%" 
        Style=" position: absolute; left: 0px; top: 40px; z-index: 105; padding: 5px;  " >    
        <asp:Panel ID="Panel2" runat="server" BorderWidth="0"  Width="99%" Style=" position: static; top: 5px; z-index: 110; padding: 5px; " >
            <table style="width: 100%; border: 0; border-color: Black; ">
                <tr>
                    <td>
                        <asp:Label ID="lblWell1" runat="server" Text="" Font-Bold="True" Font-Names="Verdana" Font-Size="Small" BackColor="#FFEA30"></asp:Label>
                        <br />
                        <ComponentArt:DataGrid ID="DataGrid1" 
                            Style="left: 0px; position: static; top: 10px; z-index: 100;" 
                            Autotheming="true"
                            CssClass="cart-datagrid"
                            RunningMode="Client"
                            AllowPaging="false" 
                            ShowFooter="false"
                            PagerStyle="Numbered"
                            AllowMultipleSelect="true"  
                            runat="server" 
                            AllowHorizontalScrolling="true"
                            Width="95%"          
                            FillContainer="true">
                            <ClientEvents>
                                <ItemSelect EventHandler="DataGrid1_onItemSelect" />
                                <ItemBeforeSelect EventHandler="DataGrid1_onItemBeforeSelect" />
                            </ClientEvents>
                            <Levels>
                              <ComponentArt:GridLevel
                                DataMember="Version"
                                DataKeyField="ID"
                                ShowSelectorCells="false" 
                                ShowHeadingCells="true"
                                SelectedRowCssClass="cart-datagrid-row-selected-1"
                                HoverRowCssClass="cart-datagrid-row-hover-1">
                                <ConditionalFormats>
                                    <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value!=DataItem.GetMember('ORIG_UWI').Value" 
                                        RowCssClass="cart-datagrid-row-2"/>
                                     <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value==DataItem.GetMember('ORIG_UWI').Value" 
                                        RowCssClass="cart-datagrid-row-1"/>
                                </ConditionalFormats> 
                                  <Columns>
                                    <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE" HeadingText="Source" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="60" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="45" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="115" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="85" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date &lt;br&gt; (dd/mm/yyyy)" Width="60" Align="Center" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill &lt;br&gt; Depth" Width="40" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface &lt;br&gt; Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface &lt;br&gt; Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole &lt;br&gt; Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole &lt;br&gt; Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="ID"  HeadingText="ID" Width="0"  Visible="false"/>                                    
                                    <ComponentArt:GridColumn DataField="ORIG_UWI"  HeadingText="ORIG_UWI" Width="0"  Visible="false"/>                                    
                                 </Columns>
                             </ComponentArt:GridLevel>
                            </Levels>
                        </ComponentArt:DataGrid>
                    </td>
                    <td style=" width: 5px">
                        <br />
                        <a href="javascript:MoveAllVersionDown();"> 
                            <img src="images/arrow_down_all.gif" title="Move All Versions Down" alt="Move All Down" style="border:0; background-color: transparent; vertical-align:middle" width="30px"/></a>
                        <br />
                        <a href="javascript:MoveVersionDown();"> 
                            <img src="images/arrow_down.gif" title="Move Selected Version(s) Down" alt="Move Down" style="border:0; background-color: transparent; vertical-align:middle" width="16px"/></a>
                    </td>
                </tr>
            </table>
        </asp:Panel>
        <asp:Panel ID="Panel3" runat="server" BorderWidth="0"  Width="99%" Style=" position: static; top: 5px; z-index: 110; padding: 5px; " >
            <table style="width: 100%; border: 0; border-color: Black; ">
                <tr>
                    <td>
                        <asp:Label ID="lblWell2" runat="server" Text="" Font-Bold="True" Font-Names="Verdana" Font-Size="Small" BackColor="#30FFEA"></asp:Label>
                        <br />
                        <ComponentArt:DataGrid ID="DataGrid2" 
                            Style="left: 0px; position: static; top: 10px; z-index: 100;" 
                            Autotheming="true"
                            CssClass="cart-datagrid"
                            RunningMode="Client"
                            AllowPaging="false" 
                            ShowFooter="false"
                            AllowMultipleSelect="true"
                            runat="server" 
                            AllowHorizontalScrolling="true"
                            Width="95%"          
                            FillContainer="true">
                            <ClientEvents>
                              <ItemSelect EventHandler="DataGrid2_onItemSelect" />
                              <ItemBeforeSelect EventHandler="DataGrid2_onItemBeforeSelect" />
                            </ClientEvents>
                            <Levels>
                              <ComponentArt:GridLevel
                                DataMember="Version"
                                DataKeyField="ID"
                                ShowSelectorCells="false"
                                ShowHeadingCells="true"
                                SelectedRowCssClass="cart-datagrid-row-selected-2"
                                HoverRowCssClass="cart-datagrid-row-hover-2">
                                <ConditionalFormats>
                                    <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value!=DataItem.GetMember('ORIG_UWI').Value" 
                                        RowCssClass="cart-datagrid-row-1"/>
                                     <ComponentArt:GridConditionalFormat  
                                        ClientFilter="DataItem.GetMember('UWI').Value==DataItem.GetMember('ORIG_UWI').Value"
                                        RowCssClass="cart-datagrid-row-2"/>
                               </ConditionalFormats> 
                                  <Columns>
                                    <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE" HeadingText="Source" Width="0" Visible="false" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="60" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="45" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="115" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="85" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date &lt;br&gt; (dd/mm/yyyy)" Width="60" Align="Center" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill &lt;br&gt; Depth" Width="40" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface &lt;br&gt; Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface &lt;br&gt; Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole &lt;br&gt; Latitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole &lt;br&gt; Longitude" Width="50" Align="Right" HeadingTextCssClass="grp-hd" AllowReordering="False"/>
                                    <ComponentArt:GridColumn DataField="ID"  HeadingText="ID" Width="0"  Visible="false"/>                                    
                                    <ComponentArt:GridColumn DataField="ORIG_UWI"  HeadingText="ORIG_UWI" Width="0"  Visible="false"/>                                    
                                 </Columns>
                                </ComponentArt:GridLevel>
                            </Levels>
                        </ComponentArt:DataGrid>
                    </td>
                    <td style=" width: 5px">
                        <br />
                        <a href="javascript:MoveVersionUp();"> 
                            <img src="images/arrow_up.gif" title="Move Selected Version(s) Up" alt="Move Up" style="border:0; background-color: transparent; vertical-align:middle" width="16px"/></a>
                        <br />
                        <a href="javascript:MoveAllVersionUp();"> 
                            <img src="images/arrow_up_all.gif" title="Move All Versions Up" alt="Move All Up" style="border:0; background-color: transparent; vertical-align:middle" width="30px"/></a>
                    </td>
                </tr>                
                <tr>
                    <td>
                        <br />
    <asp:Panel ID="pnlActionButtons" runat="server" Height="60px" Width="600px" BorderWidth="0px" Style="position: absolute; left: 15px; " >
        <asp:Button ID="btnSave" runat="server" Text="Save" Font-Bold="true" CssClass="actionbutton" OnClientClick="javascript:return confirmAction();" OnClick="btnSave_Click"/>
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" Font-Bold="true" CssClass="actionbutton"/>
        <asp:Button ID="btnReset" runat="server" Text="Reset" Font-Bold="true" CssClass="actionbutton"/>
    </asp:Panel>
                        <br />
                        <br />
                    </td>
                    <td>
                    </td>
                </tr>
            </table>            
        </asp:Panel>        
    </asp:Panel>
</asp:Content>
