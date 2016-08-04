<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/WellManager.Master" CodeBehind="Default.aspx.vb" Inherits="TalismanEnergy.WIM.iWIM._Default" 
    title="iWIM - Home" %>
<%@ Register Assembly="ComponentArt.Web.UI" Namespace="ComponentArt.Web.UI" TagPrefix="ComponentArt" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:Label ID="lblSearch" 
        runat="server" 
        Style="left: 8px; position: absolute; top: 60px; z-index: 100;" 
        Text="Search Results:" 
        Height="25px" 
        Width="200px" 
        Font-Bold="True" 
        Font-Names="Verdana" 
        Font-Size="Medium"
        Visible="false">
    </asp:Label>
    <asp:Label ID="lblMessage1" 
        runat="server" 
        Style="left: 8px; position: absolute; top: 15px; z-index: 100;" 
        Height="20px" 
        Width="100%" 
        Font-Bold="true" 
        Font-Names="Verdana" 
        Font-Size="Smaller">
    </asp:Label>
    <asp:Label ID="lblMessage2" 
        runat="server" 
        Style="left: 8px; position: absolute; top: 35px; z-index: 100;" 
        Height="20px" 
        Width="100%" 
        Font-Bold="true" 
        Font-Names="Verdana" 
        Font-Size="Smaller">
  </asp:Label>
    <div style="left: 5px; position: absolute; top: 80px; z-index: 100; width: 98%;">
    </div>
        <table style="left: 5px; position: absolute; top: 80px; z-index: 150; width: 100%;">
            <tr>
                <td  colspan="3" >    
                    <ComponentArt:DataGrid ID="DataGrid1" 
                        Autotheming="true"
                        CssClass="cart-datagrid"
                        RunningMode="Client"
                        PagerStyle="Numbered"
                        PageSize="10"
                        AllowMultipleSelect="true"
                        Width="100%"          
                        runat="server" 
                        AllowHorizontalScrolling="true"
                        IndentCellWidth="7"
                        AllowColumnResizing="true"
                        FillContainer="True"
                        Height="537px">         
                        <ClientEvents>
                          <ItemSelect EventHandler="DataGrid1_onItemSelect" />
                          <ItemBeforeSelect EventHandler="DataGrid1_onItemBeforeSelect" />
                          <ColumnResize EventHandler="DataGrid1_onColumnResize" />
                          <RenderComplete EventHandler="DataGrid1_onRenderComplete" />
                        </ClientEvents>
                        <Levels>
                          <ComponentArt:GridLevel
                            ShowSelectorCells="true"
                            DataCellCssClass="cart-datagrid-cell-1"
                            AllowReordering="false" 
                            DataMember="Well"
                            DataKeyField="UWI">
                              <Columns>
                                <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="100" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="IPL_UWI_LOCAL" HeadingText="UWI" Width="130" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="SOURCE" Visible="false" />
                                <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="85" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="90" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="130" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="PLOT_NAME" HeadingText="Plot Name" Width="130" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="90" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date &lt;br&gt; (dd/mm/yyyy)" Width="70" Align="Center" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="RIG_RELEASE_DATE" HeadingText="Rig Release Date &lt;br&gt; (dd/mm/yyyy)" Width="70" Align="Center" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="GROUND_ELEV" HeadingText="GRD Elev" Width="60" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="KB_ELEV" HeadingText="KB Elev" Width="60" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill &lt;br&gt; Depth" Width="60" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface &lt;br&gt; Latitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface &lt;br&gt; Longitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole &lt;br&gt; Latitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole &lt;br&gt; Longitude" Width="75" Align="Right" HeadingTextCssClass="grp-hd"/>
                                <ComponentArt:GridColumn DataField="LICENSE_NUM" HeadingText="License &lt;br&gt; Number" Width="60" HeadingTextCssClass="grp-hd"/>
                            </Columns>            
                          </ComponentArt:GridLevel>
                          <ComponentArt:GridLevel
                            ShowSelectorCells="true"
                            DataMember="Source"
                            DataKeyField="ID"  
                            ShowHeadingCells="false">
                              <Columns>
                                <ComponentArt:GridColumn DataField="UWI" HeadingText="TLM ID" Width="100"/>
                                <ComponentArt:GridColumn DataField="IPL_UWI_LOCAL" HeadingText="UWI" Width="130"/>
                                <ComponentArt:GridColumn DataField="SOURCE" Visible="false" />
                                <ComponentArt:GridColumn DataField="SOURCE_SHORT_NAME" HeadingText="Source" Width="85"/>
                                <ComponentArt:GridColumn DataField="COUNTRY" HeadingText="Country" Width="90"/>
                                <ComponentArt:GridColumn DataField="WELL_NAME" HeadingText="Well Name" Width="130"/>
                                <ComponentArt:GridColumn DataField="PLOT_NAME" HeadingText="Plot Name" Width="130"/>
                                <ComponentArt:GridColumn DataField="CURRENT_STATUS" HeadingText="Current Status" Width="90"/>
                                <ComponentArt:GridColumn DataField="SPUD_DATE" HeadingText="Spud Date &lt;br&gt; (dd/mm/yyyy)" Width="70" Align="Center"/>
                                <ComponentArt:GridColumn DataField="RIG_RELEASE_DATE" HeadingText="Rig Release Date &lt;br&gt; (dd/mm/yyyy)" Width="70" Align="Center"/>
                                <ComponentArt:GridColumn DataField="GROUND_ELEV" HeadingText="GRD Elev" Width="60" Align="Right"/>
                                <ComponentArt:GridColumn DataField="KB_ELEV" HeadingText="KB Elev" Width="60" Align="Right"/>
                                <ComponentArt:GridColumn DataField="DRILL_TD" HeadingText="Drill &lt;br&gt; Depth" Width="60" Align="Right"/>
                                <ComponentArt:GridColumn DataField="SURFACE_LATITUDE" HeadingText="Surface &lt;br&gt; Latitude" Width="75" Align="Right"/>
                                <ComponentArt:GridColumn DataField="SURFACE_LONGITUDE" HeadingText="Surface &lt;br&gt; Longitude" Width="75" Align="Right"/>
                                <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LATITUDE" HeadingText="Bottom Hole &lt;br&gt; Latitude" Width="75" Align="Right"/>
                                <ComponentArt:GridColumn DataField="BOTTOM_HOLE_LONGITUDE" HeadingText="Bottom Hole &lt;br&gt; Longitude" Width="75" Align="Right"/>
                                <ComponentArt:GridColumn DataField="LICENSE_NUM" HeadingText="License &lt;br&gt; Number" Width="60"/>
                                <ComponentArt:GridColumn DataField="ID"  HeadingText="ID" Width="80"  Visible="false"/>
                             </Columns>
                            </ComponentArt:GridLevel>
                        </Levels>
                    </ComponentArt:DataGrid>
                </td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
                <td>                    
                    <asp:Panel ID="pnlActionButtons" runat="server" Height="60px" Width="800px" BorderWidth="0px">
                        <input id="btnAddVersion" runat="server" type="button" disabled value="Add Version" class="actionbutton" onclick="AddVersion();"/>                        
                        <input id="btnEditVersion" runat="server" type="button" disabled value="Edit Version" class="actionbutton" onclick="EditVersion(DataGrid1.GetSelectedItems()[0]);"/>
                        <input id="btnInactivateVersion" runat="server" type="button" disabled value="Inactivate Version" class="actionbutton" onclick="InactivateVersion(DataGrid1.GetSelectedItems()[0]);"/>
                        <input id="btnDeleteVersion" runat="server" type="button" disabled value="Delete Version" class="actionbutton" onclick="DeleteVersion(DataGrid1.GetSelectedItems()[0]);"/>
                        <input id="btnMoveVersion" runat="server" type="button" disabled value="Move Version(s)" class="actionbutton" onclick="MoveVersion();"/>
                    </asp:Panel>
                </td>
                <td>
                    &nbsp;
                </td>
            </tr>
        </table>
        <script type="text/javascript">
            //<![CDATA[

            function DataGrid1_onItemSelect(sender, eventArgs) {
                if (eventArgs)
                {
                    var addallowed = document.getElementById("ctl00_ContentPlaceHolder1_AddVersionsAllowed").value;
                    if (addallowed.length > 0)
                    {
                        document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = false;
                    }                            
                    else
                    {
                        document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = true;
                    }                                       
                        
                    if (eventArgs.get_item().Level == 0) {
                        document.getElementById("ctl00_ContentPlaceHolder1_btnDeleteVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnEditVersion").disabled = true;
                        document.getElementById("ctl00_ContentPlaceHolder1_btnInactivateVersion").disabled = true;

                        var moveallowed = document.getElementById("ctl00_ContentPlaceHolder1_MoveVersionsAllowed").value;
                        if (moveallowed.length > 0)
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnMoveVersion").disabled = false;
                        }                            
                        else
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnMoveVersion").disabled = true;
                        }   
                                                            
                        var items = DataGrid1.getSelectedItems();
                        if (items)
                        {
                            if (items.length > 2)
                            {
                                DataGrid1.unSelect(items[0]);
                            }
                            else
                            {
                                if (items.length == 2)
                                {
                                    document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = true;
                                }
                                else
                                {                                   
                                    document.getElementById("ctl00_ContentPlaceHolder1_btnAddVersion").disabled = false;
                                }
                            }
                        }
                    }
                    if (eventArgs.get_item().Level == 1)
                    {
                        document.getElementById("ctl00_ContentPlaceHolder1_btnMoveVersion").disabled = true;

                        var source = DataGrid1.GetSelectedItems()[0].Data[2];
                        var deleteallowed = document.getElementById("ctl00_ContentPlaceHolder1_DeleteVersionsAllowed").value;
                        if (deleteallowed.match(source))
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnDeleteVersion").disabled = false;                            
                        }
                        else
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnDeleteVersion").disabled = true;                            
                        } 
                        
                        var editallowed = document.getElementById("ctl00_ContentPlaceHolder1_EditVersionsAllowed").value;
                        if (editallowed.match(source))
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnEditVersion").disabled = false;                            
                        }
                        else
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnEditVersion").disabled = true;                            
                        } 
                        
                        var inactivateallowed = document.getElementById("ctl00_ContentPlaceHolder1_InactivateVersionsAllowed").value;
                        if (inactivateallowed.match(source))
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnInactivateVersion").disabled = false;                            
                        }
                        else
                        {
                            document.getElementById("ctl00_ContentPlaceHolder1_btnInactivateVersion").disabled = true;                            
                        } 
                    }
                }
            }

            function DataGrid1_onItemBeforeSelect(sender, eventArgs) {
                if (eventArgs) {
                    if (eventArgs.get_item().Level == 1) {
                        DataGrid1.unSelectAll();
                    }
                    if (eventArgs.get_item().Level == 0) {
                        var items = DataGrid1.getSelectedItems()
                        if (items) if (items.length >= 1)
                            if (items[0].Level == 1)
                                DataGrid1.unSelectAll();
                    }
                }
            }
            
            function DataGrid1_onRenderComplete(sender, eventArgs){
                if ((eventArgs)&&(sender.Levels[1].Table)) {
                    for (i=0; i<sender.Levels[0].Table.Columns.length; i++){
                        sender.Levels[1].Table.Columns[i].set_width(sender.Levels[0].Table.Columns[i].get_width());
                    }
                }
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

                    if (confirm('Well [' + well.Data[0] + '] Version [' + well.Data[2] + '] will no longer be visible once INACTIVATED.\n'))
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
                        alert ("Please select single COMPOSITE well to Add version to.");
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
                        
                            location.href = "MoveVersion.aspx" + "?Wellkey2=" + escape(key);
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
    <asp:HiddenField ID="MoveVersionsAllowed" runat="server"/>                
</asp:Content>
