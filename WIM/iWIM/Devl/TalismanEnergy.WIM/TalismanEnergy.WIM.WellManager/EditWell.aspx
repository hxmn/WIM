<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/WellManager.Master" CodeBehind="EditWell.aspx.vb" Inherits="TalismanEnergy.WIM.iWIM.EditWell" 
    title="iWIM - Edit Version" %>
<%@ Register Assembly="ComponentArt.Web.UI" Namespace="ComponentArt.Web.UI" TagPrefix="ComponentArt" %>

<asp:Content ID="Content1" 
    ContentPlaceHolderID="ContentPlaceHolder1" 
    runat="server">
    <asp:Label ID="lblEditVersion" 
        runat="server" 
        Style="left: 5px; position: absolute; top: 22px; z-index: 100;" 
        Text="Edit Version"
        Height="20px" 
        Width="954px" 
        Font-Bold="True" 
        Font-Names="Verdana" 
        Font-Size="Small">
    </asp:Label>
    <asp:Label ID="lblMessage"
        runat="server" 
        Style="left: 280px; position: absolute; top: 48px; z-index: 101;" 
        Height="20px" 
        Width="600px" 
        Font-Bold="True" 
        Font-Names="Verdana" 
        Font-Size="Small" 
        ForeColor="DarkRed"  
        Visible="False"></asp:Label>
<%--    <asp:Label ID="lblMndtry" 
        runat="server" 
        Text="* = mandatory attribute" 
        Style="left: 860px; position: absolute; top: 52px; z-index: 102;" 
        Width="148px" 
        Font-Names="Verdana" 
        Font-Size="X-Small" 
        Font-Bold="False" 
        ForeColor="Blue">
    </asp:Label>--%>
    <ComponentArt:TabStrip ID="TabStrip1" 
        CssClass="TopGroup"
        AutoPostBackOnSelect="false"
        SiteMapXmlFile="App_LocalResources/WellTabs.xml"
        DefaultItemLookId="DefaultTabLook"
        DefaultSelectedItemLookId="SelectedTabLook"
        DefaultDisabledItemLookId="DisabledTabLook"
        DefaultGroupTabSpacing="1"
        ImagesBaseUrl="images/"
        MultiPageId="MultiPage1" 
        Height="1px"
        Style="left: 0px; position: absolute; top: 42px;"
        runat="server">
        <ItemLooks>
            <ComponentArt:ItemLook LookId="DefaultTabLook" 
                CssClass="DefaultTab" 
                HoverCssClass="DefaultTabHover" 
                LabelPaddingLeft="10" 
                LabelPaddingRight="10" 
                LabelPaddingTop="5" 
                LabelPaddingBottom="4" 
                LeftIconUrl="tab_left_icon.gif" 
                RightIconUrl="tab_right_icon.gif" 
                HoverLeftIconUrl="hover_tab_left_icon.gif" 
                HoverRightIconUrl="hover_tab_right_icon.gif" 
                LeftIconWidth="3" 
                LeftIconHeight="21" 
                RightIconWidth="3" 
                RightIconHeight="21" />
            <ComponentArt:ItemLook LookId="SelectedTabLook" 
                CssClass="SelectedTab" 
                LabelPaddingLeft="10" 
                LabelPaddingRight="10" 
                LabelPaddingTop="4" 
                LabelPaddingBottom="4" 
                LeftIconUrl="selected_tab_left_icon.gif" 
                RightIconUrl="selected_tab_right_icon.gif" 
                LeftIconWidth="3" 
                LeftIconHeight="21" 
                RightIconWidth="3" 
                RightIconHeight="21" />
        </ItemLooks>
    </ComponentArt:TabStrip>               
    <ComponentArt:MultiPage id="MultiPage1" 
        CssClass="MultiPage" 
        runat="server" 
        Style="left: 0px; position: absolute; top: 65px; z-index: 103;" 
        Height="517px" 
        Width="954px">
        <PageViews>
            <ComponentArt:PageView ID="PageView1"
                CssClass="PageContent" 
                runat="server">                
                <asp:Label ID="lblMessageTabStrip1"
                    runat="server" 
                    Style="left: 280px; position: absolute; top: -20px; z-index: 101;" 
                    Height="20px" 
                    Width="600px" 
                    Font-Bold="True" 
                    Font-Names="Verdana" 
                    Font-Size="Small" 
                    ForeColor="DarkRed"  
                    Visible="False"></asp:Label>
                <asp:Label ID="lblMndtry" 
                    runat="server" 
                    Text="* = mandatory attribute" 
                    Style="left: 860px; position: absolute; top: -15px; z-index: 102;" 
                    Width="148px" 
                    Font-Names="Verdana" 
                    Font-Size="X-Small" 
                    Font-Bold="False" 
                    ForeColor="Blue">
                </asp:Label>
                <asp:Panel ID="pnlSourceGroup" 
                    runat="server" 
                    Style="left: 2px; top: 0px; position: absolute;  z-index: 100;" 
                    Height="30px" 
                    Width="396px" 
                    CssClass="panel2">                        
                    <asp:Label ID="lblSourceMndtry" 
                        runat="server" 
                        Text="*" 
                        Style="left: 0px; top: 8px; z-index: 100;" 
                        CssClass="mndtryind" />
                    <asp:Label ID="lblSource" 
                        runat="server" 
                        Text="Source:" 
                        Style="left: 8px; top: 8px; z-index: 103;" 
                        CssClass="label" />                  
                    <asp:Panel ID="pnlSource"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlSource" 
                            runat="server"
                            RunningMode="CallBack"
                            AutoComplete="true" 
                            AutoFilter="true"
                            AutoHighlight="true" 
                            AutoTheming="true" 
                            DropDownHeight="160"
                            DropDownPageSize="6"
                            Enabled="false"
                            Style="left: 59px; top: 6px; position: absolute; z-index: 104;"
                            TabIndex="1"
                            Width="328px">
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse" />
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
                <asp:Panel ID="pnlIdentityGroup" 
                    runat="server" 
                    Style="left: 2px; top: 38px" 
                    Height="260px" 
                    Width="396px" 
                    CssClass="panel2">
                    <asp:Label ID="lblTLMID" 
                        runat="server" 
                        Text="TLM ID:" 
                        Style="left: 8px; top: 8px;" 
                        CssClass="label"/>
                    <asp:Label ID="lblTLMIDval" 
                        runat="server" 
                        Style="z-index: 119; left: 79px; top: 6px" 
                        Width="303px" 
                        CssClass="label"
                        Font-Bold="true"/>
                    <asp:Label ID="lblUWIMndtry" 
                        runat="server" 
                        Text="*" 
                        Style="left: 0px; top: 33px; z-index: 100;" 
                        CssClass="mndtryind" />
                    <asp:Label ID="lblUWI" 
                        runat="server" 
                        Text="UWI:" 
                        Style="left: 8px; top: 33px; z-index: 100;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtUWI" 
                        runat="server"
                        Style="z-index: 101; left: 79px; top: 31px" 
                        Width="303px"
                        MaxLength="20"
                        CssClass="inputtxtMndtryControl" 
                        TabIndex="3"></asp:TextBox>
                    <asp:Label ID="lblCountryMndtry" 
                        runat="server" 
                        Text="*" 
                        Style="left: 0px; top: 58px; z-index: 100;" 
                        CssClass="mndtryind" />
                    <asp:Label ID="lblCountry" 
                        runat="server"  
                        Text="Country:" 
                        Style=" z-index: 102; left: 8px; top: 58px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlCountry"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlCountry" 
                            runat="server"
                            RunningMode="CallBack" 
                            AutoComplete="true" 
                            AutoFilter="true"
                            AutoHighlight="true" 
                            AutoTheming="true"
                            DropDownPageSize="15"
                            Style="left: 79px; top: 56px; position: absolute; z-index: 103;"
                            TabIndex="4"
                            Width="308">
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblWellNameMndtry" 
                        runat="server" 
                        Text="*" 
                        Style="left: 0px; top: 83px; z-index: 100;" 
                        CssClass="mndtryind" />
                    <asp:Label ID="lblWellName" 
                        runat="server" 
                        Text="Well Name:" 
                        Style="left: 8px; top: 83px; z-index: 105;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtWellName" 
                        runat="server"
                        Style="z-index: 106; left: 79px; top: 81px" 
                        Width="303px"
                        MaxLength="66"
                        CssClass="inputtxtMndtryControl" 
                        TabIndex="5">
                    </asp:TextBox>
                    <asp:Label ID="lblPlotName" 
                        runat="server" 
                        Text="Plot Name:" 
                        Style="left: 8px; top: 108px; z-index: 107;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtPlotName" 
                        runat="server" 
                        Style="z-index: 108; left: 79px; top: 106px" 
                        Width="303px"
                        MaxLength="66"
                        CssClass="inputtxtControl" 
                        TabIndex="6"></asp:TextBox>
                    <asp:Label ID="lblOnOffshoreInd" 
                        runat="server"  
                        Text="On/OffShore Ind:" 
                        Style="z-index: 109; left: 8px; top: 133px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlOnOffShoreInd"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlOnOffShoreInd" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Style="left: 123px; top: 131px; position: absolute; z-index: 110;" 
                            TabIndex="7" 
                            Width="265">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="ONSHORE" Value="ONSHORE"/>
                                <ComponentArt:ComboBoxItem Text="OFFSHORE" Value="OFFSHORE"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblWellProfileType" 
                        runat="server"  
                        Text="Well Profile Type:" 
                        Style=" z-index: 111; left: 8px; top: 158px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlWellProfileType"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlWellProfileType" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="true" 
                            AutoFilter="true" 
                            AutoHighlight="true" 
                            AutoTheming="true" 
                            DropDownHeight="130"
                            DropDownPageSize="5"
                            Style="z-index: 112; left: 123px; top: 156px; position: absolute;" 
                            TabIndex="8" 
                            Width="265">
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents> 
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblCurrentStatus" 
                        runat="server"  
                        Text="Current Status:" 
                        Style=" z-index: 113; left: 8px; top: 183px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlCurrentStatus"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlCurrentStatus" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="true" 
                            AutoFilter="true" 
                            AutoHighlight="true" 
                            AutoTheming="true"                             
                            DropDownPageSize="10"
                            Style="z-index: 114; left: 123px; top: 181px; position: absolute;" 
                            TabIndex="9" 
                            Width="265">
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblOperator" 
                        runat="server"  
                        Text="Operator:" 
                        Style=" z-index: 115; left: 8px; top: 208px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlOperator"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlOperator" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="true" 
                            AutoFilter="true" 
                            AutoHighlight="true" 
                            AutoTheming="true" 
                            DropDownPageSize="20"
                            Style="z-index: 116; left: 123px; top: 206px; position: absolute;" 
                            TabIndex="10" 
                            Width="265"> 
                             <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblLicensee" 
                        runat="server"  
                        Text="Licensee:" 
                        Style=" z-index: 117; left: 8px; top: 233px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlLicensee"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlLicensee" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="true" 
                            AutoFilter="true"
                            AutoHighlight="true" 
                            AutoTheming="true"  
                            DropDownPageSize="10" 
                            Style="z-index: 118; left: 123px; top: 231px; position: absolute;" 
                            TabIndex="11"
                            Width="265"> 
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
                <asp:Panel ID="pnlElevationGroup" 
                    runat="server" 
                    Height="210px" 
                    Style="z-index: 103; left: 406px; top: 0px" 
                    Width="590px" 
                    CssClass="panel2">
                    <asp:Label ID="lblGroundElev" 
                        runat="server" 
                        Text="Ground Elev:" 
                        Style="left: 5px; top: 8px; z-index: 100;" 
                        CssClass="label"/>
                    <asp:TextBox ID="txtGroundElev" 
                        runat="server"
                        Style="z-index: 115; left: 124px; top: 6px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="12">
                        </asp:TextBox>
                    <asp:Label ID="lblGroundElevUnits" 
                        runat="server"  
                        Text="Original Units:" 
                        Style="z-index: 103; left: 230px; top: 8px" 
                        Cssclass="label"/>
                    <asp:Panel ID="pnlGroundElevUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlGroundElevUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"                            
                            DropDownPageSize="2"
                            Enabled="false"
                            Style="left: 318px; top: 6px; position: absolute; z-index: 104;" 
                            TabIndex="13"
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblDerrickFloor" 
                        runat="server" 
                        Text="Derrick Floor Elev:" 
                        Style="left: 5px; top: 98px; z-index: 100;" 
                        CssClass="label"/>
                    <asp:TextBox ID="txtDerrickFloor" 
                        runat="server" 
                        Style="z-index: 115; left: 124px; top: 96px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="18">
                        </asp:TextBox>
                    <asp:Label ID="lblDerrickFloorUnits" 
                        runat="server"  
                        Text="Original Units:" 
                        Style="z-index: 103; left: 230px; top: 98px" 
                        Cssclass="label"/>
                    <asp:Panel ID="pnlDerrickFloorUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlDerrickFloorUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false"
                            Style="left: 318px; top: 96px; position: absolute; z-index: 104;" 
                            TabIndex="19" 
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblKBElev" 
                        runat="server" 
                        Text="KB Elevation:" 
                        Style="left: 5px; top: 38px; z-index: 116;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtKBElev" 
                        runat="server" 
                        Style="z-index: 119; left: 124px; top: 36px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="14">
                    </asp:TextBox>
                    <asp:Label ID="lblKBElevUnits" 
                        runat="server"  
                        Text="Original Units:" 
                        Style="z-index: 109; left: 230px; top: 38px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlKBElevUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlKBElevUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownPageSize="2" 
                            DropDownHeight="50"
                            Enabled="false"
                            Style="left: 318px; top: 36px; position: absolute; z-index: 112;" 
                            TabIndex="15"
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblRotaryTableElev" 
                        runat="server" 
                        Text="Rotary Table Elev:" 
                        Style="left: 5px; top: 66px; z-index: 117;" 
                        CssClass="label" />
                    <asp:Label ID="lblRotaryTableMndtryUnits" 
                        runat="server" 
                        Text="(meters only)" 
                        Style="left: 5px; top: 76px; z-index: 128;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtRotaryTableElev" 
                        runat="server" 
                        Style="z-index: 120; left: 124px; top: 66px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="16">
                    </asp:TextBox>
                    <asp:Label ID="lblRotaryTableElevUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 110; left: 230px; top:68px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlRotaryTableElevUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlRotaryTableElevUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false"
                            Style="left: 318px; top: 66px; position: absolute; z-index: 110;" 
                            TabIndex="17" 
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblWaterDepth" 
                        runat="server" 
                        Text="Water Depth Elev:" 
                        Style="left: 5px; top: 128px; z-index: 117;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtWaterDepth" 
                        runat="server" 
                        Style="z-index: 120; left: 124px; top: 126px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="20">
                    </asp:TextBox>
                    <asp:Label ID="lblWaterDepthUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 110; left: 230px; top:128px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlWaterDepthUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlWaterDepthUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false"
                            Style="left: 318px; top: 126px; position: absolute; z-index: 110;" 
                            TabIndex="21" 
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblCasingFlange" 
                        runat="server" 
                        Text="Casing Flange Elev:" 
                        Style="left: 5px; top: 158px; z-index: 117;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtCasingFlange" 
                        runat="server" 
                        Style="z-index: 120; left: 124px; top: 156px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="22">
                    </asp:TextBox>
                    <asp:Label ID="lblCasingFlangeUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 110; left: 230px; top:158px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlCasingFlangeUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlCasingFlangeUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false"
                            Style="left: 318px; top: 156px; position: absolute; z-index: 110;" 
                            TabIndex="23" 
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblTotalDepth" 
                        runat="server" 
                        Text="Total Depth:" 
                        Style="left: 5px; top: 188px; z-index: 118;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtTotalDepth" 
                        runat="server" 
                        Style="z-index: 121; left: 124px; top: 186px; text-align:right;" 
                        Width="90px" 
                        CssClass="inputtxtControl"
                        AutoPostback="false" 
                        TabIndex="24"></asp:TextBox>
                    <asp:Label ID="lblTotalDepthUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 111; left: 230px; top: 188px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlTotalDepthUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlTotalDepthUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false"
                            Style="left: 318px; top: 186px; position: absolute; z-index: 114;" 
                            TabIndex="25" 
                            Width="40">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblLicenseNumber" 
                        runat="server" 
                        Text="License Number:" 
                        Style="left: 376px; top: 8px; z-index: 122;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtLicenseNumber" 
                        runat="server" 
                        Style="z-index: 123; left: 490px; top: 6px" 
                        Width="90px"
                        MaxLength="9"
                        CssClass="inputtxtControl" 
                        TabIndex="26">
                    </asp:TextBox>
                    <asp:Label ID="lblLicenseDate" 
                        runat="server" 
                        Text="License Date:" 
                        Style="left: 376px; top: 34px; z-index: 124;" 
                        CssClass="label" />
                    <asp:Label ID="lblLicenseDateFormat" 
                        runat="server" 
                        Text="(dd/mm/yyyy)" 
                        Style="left: 376px; top: 44px; z-index: 124;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtLicenseDate" 
                        runat="server" 
                        Style="z-index: 125; left: 490px; top: 36px;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="27"
                        MaxLength="10">
                    </asp:TextBox>
                    <asp:Label ID="lblRigReleaseDate" 
                        runat="server" 
                        Text="Rig Release Date:" 
                        Style="left: 376px; top: 66px; z-index: 128;" 
                        CssClass="label" />
                    <asp:Label ID="lblRigReleaseDateFormat" 
                        runat="server" 
                        Text="(dd/mm/yyyy)" 
                        Style="left: 376px; top: 76px; z-index: 128;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtRigReleaseDate" 
                        runat="server" 
                        Style="z-index: 129; left: 490px; top: 68px;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="28"
                        MaxLength="10">
                    </asp:TextBox>
                    <asp:Label ID="lblSpudDate" 
                        runat="server" 
                        Text="Spud Date:" 
                        Style="left: 376px; top: 98px; z-index: 126;" 
                        CssClass="label" />
                    <asp:Label ID="lblSpudDateFormat" 
                        runat="server" 
                        Text="(dd/mm/yyyy)" 
                        Style="left: 376px; top: 108px; z-index: 126;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtSpudDate" 
                        runat="server" 
                        Style="z-index: 127; left: 490px; top: 100px;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="29"
                        MaxLength="10"></asp:TextBox>
                    <asp:Label ID="lblFinalDrillDate" 
                        runat="server" 
                        Text="Final Drill Date:" 
                        Style="left: 376px; top: 130px; z-index: 130;" 
                        CssClass="label" />
                    <asp:Label ID="lblFinalDrillDateFormat" 
                        runat="server" 
                        Text="(dd/mm/yyyy)" 
                        Style="left: 376px; top: 140px; z-index: 130;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtFinalDrillDate" 
                        runat="server" 
                        Style="z-index: 132; left: 490px; top: 132px;" 
                        Width="90px" 
                        CssClass="inputtxtControl" 
                        TabIndex="30"
                        MaxLength="10">
                    </asp:TextBox>
                </asp:Panel>
                <asp:Panel ID="pnlBasin" 
                    runat="server" 
                    Height="85px" 
                    Style="z-index: 105; left: 406px; top: 213px" 
                    Width="590px" 
                    CssClass="panel2">
                    <asp:Label ID="lblBasin" 
                        runat="server" 
                        Text="Basin:" 
                        Style="left: 5px; top: 8px; z-index: 100;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtBasin" 
                        runat="server" 
                        Style="left: 109px; top: 6px; position: absolute; z-index: 102;" 
                        Width="107px"
                        MaxLength="12"
                        CssClass="inputtxtControl" 
                        TabIndex="31">                                                        
                    </asp:TextBox>
                    <asp:Label ID="lblArea" 
                        runat="server" 
                        Text="Area:" 
                        Style="z-index: 101; left: 232px; top: 8px" 
                        CssClass="label" />
                    <asp:TextBox ID="txtArea" 
                        runat="server" 
                        Style="left: 324px; top: 6px; position: absolute; z-index: 104;" 
                        Width="95px"
                        MaxLength="12"
                        CssClass="inputtxtControl" 
                        TabIndex="32">                                                        
                    </asp:TextBox>
                    <asp:Label ID="lblBlock" 
                        runat="server" 
                        Text="Block:" 
                        Style="z-index: 103; left: 440px; top: 8px" 
                        CssClass="label" />
                    <asp:TextBox ID="txtBlock" 
                        runat="server" 
                        Style="left: 485px; top: 6px; position: absolute; z-index: 107;" 
                        Width="95px"
                        MaxLength="12"
                        CssClass="inputtxtControl" 
                        TabIndex="33">                                                        
                    </asp:TextBox>
                    <asp:Label ID="lblProvState" 
                        runat="server" 
                        Text="Province/State:" 
                        Style="left: 5px; top: 33px; z-index: 113;" 
                        CssClass="label" />
                    <asp:Panel ID="pnlProvState"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlProvState" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="false" 
                            AutoFilter="false" 
                            AutoHighlight="true" 
                            AutoTheming="true" 
                            DropDownPageSize="10"
                            Enabled="false"
                            Style="left: 109px; top: 31px; position: absolute; z-index: 117;" 
                            TabIndex="34"
                            Width="112px">
                            <ClientEvents>
                                <Change EventHandler="provStateChange"/>
                                <CallbackComplete EventHandler="filterProvStateComplete"/>
                           </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblCounty" 
                        runat="server" 
                        Text="County:" 
                        Style="z-index: 105; left: 232px; top: 33px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlCounty"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlCounty" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="false" 
                            AutoFilter="false" 
                            AutoHighlight="true" 
                            AutoTheming="true" 
                            DropDownPageSize="10"
                            Enabled="false"
                            Style="left: 324px; top: 31px; position: absolute; z-index: 108;" 
                            TabIndex="35"
                            Width="100px">
                            <ClientEvents>
                                <CallbackComplete EventHandler="filterCountyComplete"/>
                            </ClientEvents> 
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                    <asp:Label ID="lblDistrict" 
                        runat="server" 
                        Text="District:" 
                        Style="z-index: 109; left: 440px; top: 33px" 
                        CssClass="label" />
                    <asp:TextBox ID="txtDistrict" 
                        runat="server" 
                        Style="left: 485px; top: 31px; position: absolute; z-index: 111;" 
                        Width="95px"
                        MaxLength="20"
                        CssClass="inputtxtControl" 
                        TabIndex="36">                                                        
                    </asp:TextBox>
                    <asp:Label ID="lblLeaseName" 
                        runat="server" 
                        Text="Lease Name:" 
                        Style="left: 5px; top: 58px; z-index: 114;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtLeaseName" 
                        runat="server" 
                        Style="left: 109px; top: 56px; position: absolute; z-index: 112;" 
                        Width="107px"
                        MaxLength="60"
                        CssClass="inputtxtControl" 
                        TabIndex="37">                                                        
                    </asp:TextBox>
                    <asp:Label ID="lblAssignedField" 
                        runat="server" 
                        Text="Assigned Field:" 
                        Style="z-index: 106; left: 232px; top: 58px" 
                        CssClass="label" />
                    <asp:TextBox ID="txtAssignedField" 
                        runat="server" 
                        Style="left: 324px; top: 56px; position: absolute; z-index: 118;" 
                        Width="95px"
                        MaxLength="20"
                        CssClass="inputtxtControl" 
                        TabIndex="38">                                                        
                    </asp:TextBox>
                    <asp:Label ID="lblPool" 
                        runat="server" 
                        Text="Pool:" 
                        Style="z-index: 110; left: 440px; top: 58px" 
                        CssClass="label" />
                    <asp:TextBox ID="txtPool" 
                        runat="server" 
                        Style="left: 485px; top: 56px; position: absolute; z-index: 116;" 
                        Width="95px"
                        MaxLength="18"
                        CssClass="inputtxtControl" 
                        TabIndex="39">                                                        
                    </asp:TextBox>
                </asp:Panel>                
                <asp:Panel ID="pnlLocation" 
                    runat="server"
                    Width="994px" 
                    Height="148px"
                    Style="left: 2px; top: 305px; z-index: 104;" 
                    CssClass="panel2">                        
                    <table width="100%" cellpadding="0" cellspacing="0" border="0">
                      <tr>
                        <td align="left" valign="top" style="height: 25px; font-size:small;">
                        <input type="button" onclick="NewLocationRow();" value="Add Location" id="btnAddLocation" runat="server"/> </td>
                        <td align="justify" >
                            <asp:Label ID="lblNodeMessage"
                                Text="          Please check for location error(s) below. Hover over warning icon for details."
                                runat="server" 
                                Height="20px" 
                                Width="600px" 
                                Font-Bold="True" 
                                Font-Names="Verdana" 
                                Font-Size="Small" 
                                ForeColor="DarkRed"  
                                Visible="False">
                            </asp:Label>
                        </td>
                      </tr>
                    </table>
                    <ComponentArt:DataGrid ID="DataGrid1" 
                        AutoTheming="true"
                        EnableViewState="false"
                        RunningMode="Callback"
                        AutoCallBackOnInsert="true"
                        AutoCallBackOnUpdate="true"
                        AutoCallBackOnDelete="true"
                        AllowEditing="True"
                        Width="993"
                        Height="100"
                        runat="server"
                        AllowTextSelection="True"  
                        PageSize="100"
                        AllowPaging="False"
                        ShowFooter="false"        
                        FillContainer="false" 
                        AllowColumnResizing="False" 
                        AllowHtmlContent="False" 
                        AllowMultipleSelect="False" 
                        AllowVerticalScrolling="True" 
                        AutoFocusSearchBox="False" 
                        AutoSortOnGroup="False"  
                        ColumnResizeDistributeWidth="false" 
                        LoadingPanelEnabled="False" 
                        ManualPaging="false" 
                        ClientScriptLocation="" 
                        CallbackReloadTemplates="False"
                        EditOnClickSelectedItem="false"
                        Debug="false">
                        <ClientEvents>
                            <CallbackError EventHandler="DataGrid1_onCallbackError"/>
                            <ItemBeforeUpdate EventHandler="DataGrid1_onItemBeforeUpdate"/>
                            <ItemBeforeInsert EventHandler="DataGrid1_onItemBeforeInsert"/>
                            <ItemBeforeDelete EventHandler="DataGrid1_onItemBeforeDelete"/>
                        </ClientEvents>
                        <Levels>
                           <ComponentArt:GridLevel
                                DataKeyField="LIST_ID"  
                                AllowReordering="False"
                                AllowGrouping="False"
                                AllowSorting="True"
                                EditCommandClientTemplateId="EditCommandTemplate" 
                                InsertCommandClientTemplateId="InsertCommandTemplate"> 
                                <Columns>
                                    <ComponentArt:GridColumn AllowEditing="False"
                                                             DataField="LIST_ID" 
                                                             Width="10"
                                                             FixedWidth="true"
                                                             HeadingText="ListId"
                                                             Visible="false"/>
                                    <%--<ComponentArt:GridColumn AllowEditing="False"
                                                             DataField="WIM_SEQ" 
                                                             Width="10"
                                                             FixedWidth="true"
                                                             HeadingText="WimSeq"
                                                             Visible="false"/>--%>
                                    <ComponentArt:GridColumn AllowEditing="False"
                                                             DataField="ErrorMessage" 
                                                             Width="25"
                                                             FixedWidth="true"
                                                             HeadingText="  "
                                                             DataCellClientTemplateId="MessageTemplate" 
                                                             Visible="false"/>
                                    <ComponentArt:GridColumn AllowEditing="False" 
                                                             DataField="NODE_OBS_NO" 
                                                             Width="60"
                                                             FixedWidth="true"
                                                             HeadingText="Obs No."/>
                                    <ComponentArt:GridColumn DataField="NODE_POSITION" 
                                                             HeadingText="Position" 
                                                             Width="60"
                                                             FixedWidth="true"
                                                             ForeignTable="PositionLookUp" 
                                                             ForeignDataKeyField="NODE_POSITION" 
                                                             ForeignDisplayField="NODE_POSITION_LONGNAME" 
                                                             EditControlType="Custom"/>
                                    <ComponentArt:GridColumn DataField="LATITUDE" 
                                                             HeadingText="Latitude" 
                                                             Width="140"
                                                             FixedWidth="true"/>
                                    <ComponentArt:GridColumn DataField="LONGITUDE" 
                                                             HeadingText="Longitude" 
                                                             Width="140"
                                                             FixedWidth="true"/>
                                    <ComponentArt:GridColumn DataField="GEOG_COORD_SYSTEM_ID" 
                                                             HeadingText="Geographic Datum" 
                                                             Width="300"
                                                             FixedWidth="true"
                                                             ForeignTable="CoordinateSystemLookUp" 
                                                             ForeignDataKeyField="COORD_SYSTEM_ID"
                                                             ForeignDisplayField="COORD_SYSTEM_NAME" 
                                                             EditControlType="Custom"/>
                                    <ComponentArt:GridColumn AllowSorting="False" 
                                                             Width="60"
                                                             FixedWidth="true"
                                                             HeadingText="" 
                                                             DataCellClientTemplateId="EditTemplate" 
                                                             EditControlType="EditCommand"/>
                                </Columns>
                                <ConditionalFormats>
                                    <ComponentArt:GridConditionalFormat 
                                        ClientFilter="DataItem.GetMember('ErrorMessage').Value!=null && DataItem.GetMember('ErrorMessage').Value!=''" 
                                        RowCssClass="cart-datagrid-row-error"
                                        HoverRowCssClass="cart-datagrid-row-error" 
                                        SelectedHoverRowCssClass="cart-datagrid-row-error"
                                        SelectedRowCssClass="cart-datagrid-row-error"/>
                                </ConditionalFormats>
                            </ComponentArt:GridLevel>
                        </Levels>
                        <ClientTemplates>
                            <ComponentArt:ClientTemplate Id="EditTemplate" runat="server"  >
                                <a href="javascript:DataGrid1.edit(DataGrid1.getItemFromClientId('## DataItem.ClientId ##'));">
                                    <img src="images/EditButton.png" title="Edit" alt="Edit" style="border:0; vertical-align:middle" /></a> &nbsp; 
                                <a href="javascript:deleteRow('## DataItem.ClientId ##')"> 
                                    <img src="images/DeleteButton.png" title="Delete" alt="Delete" style="border:0; background-color: transparent; vertical-align:middle" /></a>
                            </ComponentArt:ClientTemplate>
                            <ComponentArt:ClientTemplate Id="EditCommandTemplate" runat="server" >
                                <a href="javascript:DataGrid1.editComplete();"> 
                                    <img src="images/SaveButton.png" title="Save" alt="Save" style="border:0; background-color: transparent; vertical-align:middle" /></a> &nbsp; 
                                <a href="javascript:DataGrid1.editCancel();"> 
                                    <img src="images/CancelButton.png" title="Cancel" alt="Cancel" style="border:0; background-color: transparent; vertical-align:middle" /></a>
                            </ComponentArt:ClientTemplate>
                            <ComponentArt:ClientTemplate Id="InsertCommandTemplate" runat="server" >
                                <a href="javascript:DataGrid1.editComplete();"> 
                                    <img src="images/SaveButton.png" title="Save" alt="Save" style="border:0; background-color: transparent; vertical-align:middle" /></a> &nbsp; 
                                <a href="javascript:DataGrid1.EditCancel();"> 
                                    <img src="images/CancelButton.png" title="Cancel" alt="Cancel" style="border:0; background-color: transparent; vertical-align:middle" /></a>
                            </ComponentArt:ClientTemplate>          
                            <ComponentArt:ClientTemplate Id="MessageTemplate" runat="server"  >
                                ## SetErrorMessage(DataItem) ##
                            </ComponentArt:ClientTemplate>
                        </ClientTemplates>                        
                    </ComponentArt:DataGrid>
                    
<script type="text/javascript">

//********* Start  Location DataGrid Events ***********//
function DataGrid1_onCallbackError(sender, eventArgs)
{
    if (confirm('Invalid data has been entered. View details?'))
    {
        alert(eventArgs.get_errorMessage());
        DataGrid1.page(0);
        DataGrid1.scrollTo(DataGrid1.Table.getRowCount());
    }
}

function DataGrid1_onItemBeforeDelete(sender, eventArgs)
{
    if (!confirm("Delete this location record?"))
    {
        eventArgs.set_cancel(true);
    }
}

function DataGrid1_onItemBeforeInsert(sender, eventArgs)
{
    var newItem = eventArgs.get_item();
    return ValidateRow(sender, eventArgs, newItem);                 
}

function DataGrid1_onItemBeforeUpdate(sender, eventArgs)
{
    var newItem = eventArgs.get_newItem();
    return ValidateRow(sender, eventArgs, newItem) ;                 
}

function ValidateRow(sender, eventArgs, newItem)
{
    var errMsg = "";
    
    // validate Latitude
    var _Latitude = newItem.getMember("LATITUDE").get_value();
    var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,7}|)$/  // -99,999.99999
    if ((!isValidPattern(_Latitude, pat))) 
    {
        // failed validation, return to editing
        errMsg += "Latitude format should be 99999.9999999\n";
    }
    
    // validate Longitude
    var _Longitude = newItem.getMember("LONGITUDE").get_value();
    var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,7}|)$/  // -99,999.99999
    if ((!isValidPattern(_Longitude, pat))) 
    {
        // failed validation
        errMsg += "Longitude format should be 99999.9999999\n";
    }
    
    // Overall result
    if (!errMsg == "")
    {
        window.alert(
        "The following fields have not been correctly filled out:\n\n"
        + errMsg);
        eventArgs.set_continue(true);
        return false;
    }
    else
    {
        return true;
    }
}

function NewLocationRow()
{
    DataGrid1.Table.AddRow(); 
}

function editGrid(rowId)
{
    DataGrid1.edit(DataGrid1.getItemFromClientId(rowId));
}

function editRow()
{
    DataGrid1.editComplete();
}

function insertRow()
{
    DataGrid1.editComplete();
}

function deleteRow(rowId)
{
    DataGrid1.deleteItem(DataGrid1.getItemFromClientId(rowId));
}

function SetErrorMessage(item)
{
    if(item.GetMember('ErrorMessage').Text != ''){ 
        //var ErrorMessage = item.GetMember('ErrorMessage').Text.split(';').join('\n') ;
        var ErrorMessageTitle = item.GetMember('ErrorMessage').Text.split(';').join('\r') ;
        //var ErrorMessage = ErrorMessageTitle.replace(/(\r\n|\r|\n)/g,'\n') ; 'onclick="javascript:alert(\'' + ErrorMessage + '\');" ' + 
        var showErrorIcon = '<img src="images/warning.gif" ' +  'title="' + ErrorMessageTitle + '" ' +
                            ' style="background-color:Yellow; border:0; vertical-align:middle; width:16; height:16; " > &nbsp; </img>';
        return showErrorIcon ; 
    } 
    else 
        return '';
}
//********* End  Location DataGrid Events ***********//            

//********* Start Generic Comboboxes Events ***********//
//Allow user to be able to type, but not select anything that is not available in the item list//
function ddlCollapse(sender, eventArgs) {
    if (sender.get_text() == "") {
        if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlSource") {
            sender.focus();
        }
        return;
    }
    
    var i = 0;
    var item;
    
    while (sender.getItem(i)) {
        if (sender.get_text() == sender.getItem(i).get_text()) {
            item = sender.getItem(i);
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlSource") {
                document.getElementById("ctl00_ContentPlaceHolder1_lblSource2val").innerText = item.Text;
                ddlSource.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlCountry") {
                ddlCountry.selectItem(item);
                document.getElementById("ctl00_ContentPlaceHolder1_lblCountry2val").innerText = item.Text;

                ddlCounty.set_text("");
                ddlCounty.disable();
                
                ddlProvState.FilterString = "";
                ddlProvState.CallbackFilterString = "";
                ddlProvState.set_text("");
                ddlProvState.disable();
                ddlProvState.filter(item.get_value());
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlOnOffShoreInd") {
                ddlOnOffShoreInd.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlWellProfileType") {
                ddlWellProfileType.selectItem(item);
                var vertical = "V";
                if (item.Value == vertical)
                {
                    document.getElementById("ctl00_ContentPlaceHolder1_txtPlugbackTVD").disabled = true;
                    document.getElementById("ctl00_ContentPlaceHolder1_txtMaxTVD").disabled = true;
                }
                else
                {
                    document.getElementById("ctl00_ContentPlaceHolder1_txtPlugbackTVD").disabled = false;
                    document.getElementById("ctl00_ContentPlaceHolder1_txtMaxTVD").disabled = false;
                }
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlCurrentStatus") {
                ddlCurrentStatus.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlOperator") {
                ddlOperator.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlLicensee") {
                ddlLicensee.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlGroundElevUnits") {
                ddlGroundElevUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlKBElevUnits") {
                ddlKBElevUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlDerrickFloorUnits") {
                ddlDerrickFloorUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlWaterDepthUnits") {
                ddlWaterDepthUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlCasingFlangeUnits") {
                ddlCasingFlangeUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlTotalDepthUnits") {
                ddlTotalDepthUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlOldestStratAge") {
                ddlOldestStratAge.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlTDStratAge") {
                ddlTDStratAge.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlPlugbackDepthUnits") {
                ddlPlugbackDepthUnits.selectItem(item);
            }
            if (sender.get_id() == "ctl00_ContentPlaceHolder1_ddlMaxTVDUnits") {
                ddlMaxTVDUnits.selectItem(item);
            }
            return;
        }
        i++;
    }
    sender.set_text("");
    sender.toggleExpand();
    sender.focus();
}
//********* End Generic Comboboxes Events ***********//

//********* Start UWI Events ***********//
function handleUWI()
{
    var field = document.getElementById("ctl00_ContentPlaceHolder1_txtUWI");
    if (field)
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblUWI2val").innerText = field.value;
    }
}
//********* End   UWI Events ***********//

//********* Start WellName Events ***********//
function handleWellName()
{
    var field = document.getElementById("ctl00_ContentPlaceHolder1_txtWellName");
    if (field)
    {
        document.getElementById("ctl00_ContentPlaceHolder1_lblWellName2val").innerText = field.value;
    }
}
//********* End   WellName Events ***********//

//********* Start Country, Province/State, County Comboboxes Events ***********//            
function filterProvStateComplete(sender, eventArgs)
{
    var itemcnt = sender.get_itemCount();
    
    if (itemcnt > 0)
    {
        ddlProvState.enable();
    }
    else
    {
        ddlProvState.disable();
    }
}
                  
function provStateChange(sender, eventArgs)
{
    var item = sender.getSelectedItem();
    if (item)
    {
        ddlCounty.set_text("");
        ddlCounty.disable();
        ddlCounty.filter(item.get_value());
    }
}

function filterCountyComplete(sender, eventArgs)
{
    var itemcnt = sender.get_itemCount();
    
    if (itemcnt > 0)
    {
        ddlCounty.enable();
    }
    else
    {
        ddlCounty.disable();
    }
}
//********* End  Country, Prvince-state, County Comboboxes Events ***********//  

//********* Start Elevation Groups Input and Comboboxes Events ***********//            
function isValidPattern( value, re) 
{
    if (!value.match(re)) 
        return false;
      else  
        return true;
}

function handleGroundElev()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtGroundElev");
    var unit = ddlGroundElevUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlGroundElevUnits.set_text("");
                    ddlGroundElevUnits.SelectedIndex = -1;
                    ddlGroundElevUnits.collapse;
                }
                ddlGroundElevUnits.enable();
                ddlGroundElevUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {            
                    ddlGroundElevUnits.set_text("");
                    ddlGroundElevUnits.SelectedIndex = -1;
                    ddlGroundElevUnits.collapse;
                    ddlGroundElevUnits.disable();
                }
                alert("Ground Elevation format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
        else
        {
            if (unit.length > 0)
            {       
                ddlGroundElevUnits.set_text("");
                ddlGroundElevUnits.SelectedIndex = -1;
                ddlGroundElevUnits.collapse;
                ddlGroundElevUnits.disable();
            }
        }
    }
    else
    {
        ddlGroundElevUnits.set_text("");
        ddlGroundElevUnits.SelectedIndex = -1;
        ddlGroundElevUnits.collapse;
        ddlGroundElevUnits.disable();
    }
}

function handleKBElev()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtKBElev");
    var unit = ddlKBElevUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlKBElevUnits.set_text("");
                    ddlKBElevUnits.SelectedIndex = -1;
                    ddlKBElevUnits.collapse;
                }
                ddlKBElevUnits.enable();
                ddlKBElevUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {            
                    ddlKBElevUnits.set_text("");
                    ddlKBElevUnits.SelectedIndex = -1;
                    ddlKBElevUnits.collapse;
                    ddlKBElevUnits.disable();
                }
                alert("KB Elevation format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
        else
        {
            if (unit.length > 0)
            {       
                ddlKBElevUnits.set_text("");
                ddlKBElevUnits.SelectedIndex = -1;
                ddlKBElevUnits.collapse;
                ddlKBElevUnits.disable();
            }
        }
    }
    else
    {
        ddlKBElevUnits.set_text("");
        ddlKBElevUnits.SelectedIndex = -1;
        ddlKBElevUnits.collapse;
        ddlKBElevUnits.disable();
    }
}

function handleRotaryTableElev()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtRotaryTableElev");
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((!isValidPattern(elev.value, pat))) 
            {
                alert("Rotary Table Elevation format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
    }
}

function handleDerrickFloor()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtDerrickFloor");
    var unit = ddlDerrickFloorUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlDerrickFloorUnits.set_text("");
                    ddlDerrickFloorUnits.SelectedIndex = -1;
                    ddlDerrickFloorUnits.collapse;
                }
                ddlDerrickFloorUnits.enable();
                ddlDerrickFloorUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {
                    ddlDerrickFloorUnits.set_text("");
                    ddlDerrickFloorUnits.SelectedIndex = -1;
                    ddlDerrickFloorUnits.collapse;
                    ddlDerrickFloorUnits.disable();
                }
                alert("Derrick Floor Elevation format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
        else
        {
            if (unit.length > 0)
            {
                ddlDerrickFloorUnits.set_text("");
                ddlDerrickFloorUnits.SelectedIndex = -1;
                ddlDerrickFloorUnits.collapse;
                ddlDerrickFloorUnits.disable();
            }
        }
    }
    else
    {
        ddlDerrickFloorUnits.set_text("");
        ddlDerrickFloorUnits.SelectedIndex = -1;
        ddlDerrickFloorUnits.collapse;
        ddlDerrickFloorUnits.disable();
    }
}

function handleWaterDepth()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtWaterDepth");
    var unit = ddlWaterDepthUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlWaterDepthUnits.set_text("");
                    ddlWaterDepthUnits.SelectedIndex = -1;
                    ddlWaterDepthUnits.collapse;
                }
                ddlWaterDepthUnits.enable();
                ddlWaterDepthUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {
                    ddlWaterDepthUnits.set_text("");
                    ddlWaterDepthUnits.SelectedIndex = -1;
                    ddlWaterDepthUnits.collapse;
                    ddlWaterDepthUnits.disable();
                }
                alert("Water Depth Elevation format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
        else
        {
            if (unit.length > 0)
            {
                ddlWaterDepthUnits.set_text("");
                ddlWaterDepthUnits.SelectedIndex = -1;
                ddlWaterDepthUnits.collapse;
                ddlWaterDepthUnits.disable();
            }
        }
    }
    else
    {
        ddlWaterDepthUnits.set_text("");
        ddlWaterDepthUnits.SelectedIndex = -1;
        ddlWaterDepthUnits.collapse;
        ddlWaterDepthUnits.disable();
    }    
}

function handleCasingFlange()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtCasingFlange");
    var unit = ddlCasingFlangeUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlCasingFlangeUnits.set_text("");
                    ddlCasingFlangeUnits.SelectedIndex = -1;
                    ddlCasingFlangeUnits.collapse;
                }
                ddlCasingFlangeUnits.enable();
                ddlCasingFlangeUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {
                    ddlCasingFlangeUnits.set_text("");
                    ddlCasingFlangeUnits.SelectedIndex = -1;
                    ddlCasingFlangeUnits.collapse;
                    ddlCasingFlangeUnits.disable();
                }
                alert("Casing Flange Elevation format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
        else
        {
            if (unit.length > 0)
            {
                ddlCasingFlangeUnits.set_text("");
                ddlCasingFlangeUnits.SelectedIndex = -1;
                ddlCasingFlangeUnits.collapse;
                ddlCasingFlangeUnits.disable();
            }
        }
    }
    else
    {
        ddlCasingFlangeUnits.set_text("");
        ddlCasingFlangeUnits.SelectedIndex = -1;
        ddlCasingFlangeUnits.collapse;
        ddlCasingFlangeUnits.disable();
    }
}

function handleTotalDepth()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtTotalDepth");
    var unit = ddlTotalDepthUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlTotalDepthUnits.set_text("");
                    ddlTotalDepthUnits.SelectedIndex = -1;
                    ddlTotalDepthUnits.collapse;
                }
                ddlTotalDepthUnits.enable();
                ddlTotalDepthUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {
                    ddlTotalDepthUnits.set_text("");
                    ddlTotalDepthUnits.SelectedIndex = -1;
                    ddlTotalDepthUnits.collapse;
                    ddlTotalDepthUnits.disable();
                }
                alert("Total Depth format should be 99999.99999"); 
                elev.value = "";
                elev.focus(); 
            }
        }
        else
        {
            if (unit.length > 0)
            {
                ddlTotalDepthUnits.set_text("");
                ddlTotalDepthUnits.SelectedIndex = -1;
                ddlTotalDepthUnits.collapse;
                ddlTotalDepthUnits.disable();
            }
        }
    }
    else
    {
        ddlTotalDepthUnits.set_text("");
        ddlTotalDepthUnits.SelectedIndex = -1;
        ddlTotalDepthUnits.collapse;
        ddlTotalDepthUnits.disable();
    }
}

function handlePlugbackDepth()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtPlugbackDepth");
    var unit = ddlPlugbackDepthUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99,999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlPlugbackDepthUnits.set_text("");
                    ddlPlugbackDepthUnits.SelectedIndex = -1;
                    ddlPlugbackDepthUnits.collapse;
                }
                ddlPlugbackDepthUnits.enable();
                ddlPlugbackDepthUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {
                    ddlPlugbackDepthUnits.set_text("");
                    ddlPlugbackDepthUnits.SelectedIndex = -1;
                    ddlPlugbackDepthUnits.collapse;
                    ddlPlugbackDepthUnits.disable();
                }
                alert("Plugback Depth format should be 99999.99999"); 
                elev.value = "";
                elev.focus();                          
            }
        }
        else
        {
            if (unit.length > 0)
            {
                ddlPlugbackDepthUnits.set_text("");
                ddlPlugbackDepthUnits.SelectedIndex = -1;
                ddlPlugbackDepthUnits.collapse;
                ddlPlugbackDepthUnits.disable();
            }
        }
    }
    else
    {
        ddlPlugbackDepthUnits.set_text("");
        ddlPlugbackDepthUnits.SelectedIndex = -1;
        ddlPlugbackDepthUnits.collapse;
        ddlPlugbackDepthUnits.disable();
    }
}

function handlePlugbackTVD()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtPlugbackTVD");
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99,999.99999
            if ((!isValidPattern(elev.value, pat))) 
            {
                alert("Plugback TVD format should be 99999.99999"); 
                elev.value = "";
                elev.focus();                          
            }
        }
    }
}

function handleMaxTVD()
{
    var elev = document.getElementById("ctl00_ContentPlaceHolder1_txtMaxTVD");
    var unit = ddlMaxTVDUnits.get_text();
    if (elev != null)
    {
        if (elev.value.length > 0)
        {
            var pat = /^-?\d{0,2}\,?\d{0,3}(\.\d{0,5}|)$/  // -99,999.99999
            if ((isValidPattern(elev.value, pat))) 
            {
                if (unit.length > 0)
                {
                    ddlMaxTVDUnits.set_text("");
                    ddlMaxTVDUnits.SelectedIndex = -1;
                    ddlMaxTVDUnits.collapse;
                }
                ddlMaxTVDUnits.enable();
                ddlMaxTVDUnits.focus();
            }
            else
            {
                if (unit.length > 0)
                {
                    ddlMaxTVDUnits.set_text("");
                    ddlMaxTVDUnits.SelectedIndex = -1;
                    ddlMaxTVDUnits.collapse;
                    ddlMaxTVDUnits.disable();
                }
                alert("Max TVD format should be 99999.99999"); 
                elev.value = "";
                elev.focus();                          
            }
        }
        else
        {
            if (unit.length > 0)
            {
                ddlMaxTVDUnits.set_text("");
                ddlMaxTVDUnits.SelectedIndex = -1;
                ddlMaxTVDUnits.collapse;
                ddlMaxTVDUnits.disable();
            }
        }
    }
    else
    {
        ddlMaxTVDUnits.set_text("");
        ddlMaxTVDUnits.SelectedIndex = -1;
        ddlMaxTVDUnits.collapse;
        ddlMaxTVDUnits.disable();
    }
}
//********* End   Elevation Groups Input and Comboboxes Events ***********//

//********* Start Date Events ***********//
function handleLicenseDate()
{
    var field = document.getElementById("ctl00_ContentPlaceHolder1_txtLicenseDate");
    if (field != null && field.value.length > 0)
    {
        if (!isValidDate(field.value))
        {
            document.getElementById("ctl00_ContentPlaceHolder1_txtLicenseDate").value = "";
            field.focus();
        }
    }
}

function handleRigReleaseDate()
{
    var field = document.getElementById("ctl00_ContentPlaceHolder1_txtRigReleaseDate");
    if (field != null && field.value.length > 0)
    {
        if (!isValidDate(field.value))
        {
            document.getElementById("ctl00_ContentPlaceHolder1_txtRigReleaseDate").value = "";
            field.focus();
        }
    }
}

function handleSpudDate()
{
    var field = document.getElementById("ctl00_ContentPlaceHolder1_txtSpudDate");
    if (field != null && field.value.length > 0)
    {
        if (!isValidDate(field.value))
        {
            document.getElementById("ctl00_ContentPlaceHolder1_txtSpudDate").value = "";
            field.focus();
        }
    }
}

function handleFinalDrillDate()
{
    var field = document.getElementById("ctl00_ContentPlaceHolder1_txtFinalDrillDate");
    if (field != null && field.value.length > 0)
    {
        if (!isValidDate(field.value))
        {
            document.getElementById("ctl00_ContentPlaceHolder1_txtLicenseDate").value = "";
            field.focus();
        }
    }
}

function isValidDate(dateStr)
{
    var datePat = /^(\d{1,2})(\/)(\d{1,2})\2(\d{4})$/;
    var matchArray = dateStr.match(datePat); // is the format ok?
    
    if (matchArray == null)
    {
        alert("Date is not in a valid format.")
        return false;
    }
    
    day = matchArray[1];
    month = matchArray[3]; // parse date into variables
    year = matchArray[4];
    
    if (month < 1 || month > 12)
    { // check month range
        alert("Month must be between 1 and 12.");
        return false;
    }
    
    if (day < 1 || day > 31)
    {
        alert("Day must be between 1 and 31.");
        return false;
    }
    
    if ((month==4 || month==6 || month==9 || month==11) && day==31)
    {
        alert("Month "+month+" doesn't have 31 days!");
        return false;
    }
    
    if (month == 2)
    { // check for february 29th
        var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
        if (day>29 || (day==29 && !isleap))
        {
            alert("February " + year + " doesn't have " + day + " days!");
            return false;
        }
    }
    
    var currentDate = new Date();
    var currMonth = currentDate.getMonth() + 1;
    var currDay = currentDate.getDate();
    var currYear = currentDate.getFullYear();
    
    var inputDate = new Date(year, month, day);
    var todayDate = new Date(currYear, currMonth, currDay);
    
    if (inputDate > todayDate)
    {
        alert("Future dates not accepted!");
        return false;
    }

    return true;  // date is valid
}
//********* End   Date Events ***********//

//********* Start Disable Enter Key ***********//
function stopEnterKey(evt) { 
  var evt = (evt) ? evt : ((event) ? event : null); 
  var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null); 
  if ((evt.keyCode == 13))  {return false;} 
} 
document.onkeypress = stopEnterKey; 
//********* End   Disable Enter Key ***********//
</script>                  
                </asp:Panel>                   
            </ComponentArt:PageView>
            <ComponentArt:PageView ID="PageView2"
                CssClass="PageContent" 
                runat="server">          
                <asp:Label ID="lblMessageTabStrip2"
                    runat="server" 
                    Style="left: 280px; position: absolute; top: -20px; z-index: 101;" 
                    Height="20px" 
                    Width="600px" 
                    Font-Bold="True" 
                    Font-Names="Verdana" 
                    Font-Size="Small" 
                    ForeColor="DarkRed"  
                    Visible="False"></asp:Label>
                <asp:Panel ID="pnlSourceGroup2" 
                    runat="server" 
                    Style="left: 2px; top: 0px" 
                    Height="30px" 
                    Width="455px" 
                    CssClass="panel2">
                    <asp:Label ID="lblSource2" 
                        runat="server" 
                        Text="Source:" 
                        Style="left: 8px; top: 8px; z-index: 100;" 
                        CssClass="label" />
                    <asp:Label ID="lblSource2val" 
                        runat="server" 
                        Style="left: 59px; top: 8px; z-index: 101;" 
                        Width="220px" 
                        CssClass="label" 
                        TabIndex="1" />
                    <asp:Label ID="lblActiveInd2" 
                        runat="server" 
                        Text="Active Indicator:" 
                        Style="left: 301px; top: 8px; z-index: 103;" 
                        CssClass="label"
                        Visible="false"/>
                    <asp:Label ID="lblActiveInd2val" 
                        runat="server" 
                        Style="left: 400px; top: 8px; z-index: 104;" 
                        Width="52px" 
                        CssClass="label" 
                        TabIndex="2"
                        Visible="false"/>
                </asp:Panel>
                <asp:Panel ID="pnlIdentityGroup2" 
                    runat="server" 
                    Style="left: 2px; top: 38px" 
                    Height="110px" 
                    Width="455px" 
                    CssClass="panel2">
                    <asp:Label ID="lblTLMID2" 
                        runat="server" 
                        Text="TLM ID:" 
                        Style="left: 8px; top: 8px; z-index: 120;" 
                        CssClass="label" />
                    <asp:Label ID="lblTLMID2val" 
                        runat="server" 
                        Style="z-index: 119; left: 79px; top: 8px" 
                        Width="365px" 
                        CssClass="label"
                        Font-Bold="true"/>
                    <asp:Label ID="lblUWI2" 
                        runat="server" 
                        Text="UWI:" 
                        Style="left: 8px; top: 33px; z-index: 100;" 
                        CssClass="label" />
                    <asp:Label ID="lblUWI2val" 
                        runat="server" 
                        Style="z-index: 101; left: 79px; top: 33px" 
                        Width="365px" 
                        CssClass="label" 
                        TabIndex="3"/>
                    <asp:Label ID="lblCountry2" 
                        runat="server"  
                        Text="Country:" 
                        Style=" z-index: 102; left: 8px; top: 58px" 
                        CssClass="label" />
                    <asp:Label ID="lblCountry2val" 
                        runat="server" 
                        Style="z-index: 103; left: 79px; top: 58px" 
                        Width="372px" 
                        CssClass="label" 
                        TabIndex="4" />
                    <asp:Label ID="lblWellName2" 
                        runat="server" 
                        Text="Well Name:" 
                        Style="left: 8px; top: 83px; z-index: 105;" 
                        CssClass="label" />
                    <asp:Label ID="lblWellName2val" 
                        runat="server" 
                        Style="z-index: 106; left: 79px; top: 83px" 
                        Width="365px" 
                        CssClass="label" 
                        TabIndex="5" />
                </asp:Panel>
                <asp:Panel ID="pnlOSA" 
                    runat="server" 
                    Height="30px" 
                    Width="455px" 
                    Style="left: 2px; top: 156px; z-index: 109;" 
                    CssClass="panel2">
                    <asp:Label ID="lblOldestStratAge" 
                        runat="server" 
                        Text="Oldest Strat Age:" 
                        Style="z-index: 104; left: 4px; top: 8px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlOldestStratAge"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlOldestStratAge" 
                            runat="server" 
                            RunningMode="CallBack"
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownPageSize="10" 
                            Style="left: 110px; top: 6px; position: absolute; z-index: 101;" 
                            TabIndex="40"
                            Width="320">
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
                <asp:Panel ID="pnlTDSA"
                    runat="server" 
                    Height="30px" 
                    Width="455px" 
                    Style="left: 2px; top: 194px; z-index: 109;" 
                    CssClass="panel2">                    
                    <asp:Label ID="lblTDStratAge" 
                        runat="server" 
                        Text="TD Strat Age:" 
                        Style="z-index: 102; left: 4px; top: 8px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlTDStratAge"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlTDStratAge" 
                            runat="server" 
                            RunningMode="CallBack" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownPageSize="10"
                            Style="left: 110px; top: 6px; position: absolute; z-index: 102;" 
                            TabIndex="41" 
                            Width="320">
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
                <asp:Panel ID="pnlPlugbackDepth" 
                    runat="server" 
                    Height="30px" 
                    Width="455px" 
                    Style="left: 2px; top: 232px; z-index: 103;" 
                    CssClass="panel2">
                    <asp:Label ID="lblPlugbackDepth" 
                        runat="server" 
                        Text="Plugback Depth:" 
                        Style="z-index: 104; left: 4px; top: 8px" 
                        CssClass="label" />
                    <asp:TextBox ID="txtPlugbackDepth" 
                        runat="server" 
                        Style="z-index: 101; left: 110px; top: 6px; text-align:right;" 
                        Width="122px" 
                        CssClass="inputtxtControl" 
                        TabIndex="42">
                    </asp:TextBox>
                    <asp:Label ID="lblPlugbackDepthUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 102; left: 249px; top: 8px" 
                        CssClass="label" />
                    <asp:Panel ID="pnlPlugbackDepthUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlPlugbackDepthUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false" 
                            Style="left: 332px; top: 6px; position: absolute; z-index: 103;" 
                            TabIndex="43"
                            Width="98">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
                <asp:Panel ID="pnlPlugbackTVD" 
                    runat="server" 
                    Height="30px" 
                    Width="455px" 
                    Style="left: 2px; top: 270px; z-index: 102;" 
                    CssClass="panel2">
                    <asp:Label ID="lblPlugbackTVD" 
                        runat="server" 
                        Text="Plugback TVD:" 
                        Style="z-index: 104; left: 4px; top: 6px" 
                        CssClass="label"/>
                    <asp:Label ID="lblPlugbackTVDMntryUnits" 
                        runat="server" 
                        Text="(meters only)" 
                        Style="left: 4px; top: 16px; z-index: 128;" 
                        CssClass="label" />
                    <asp:TextBox ID="txtPlugbackTVD" 
                        runat="server" 
                        Style="z-index: 101; left: 110px; top: 6px; text-align:right;" 
                        Width="122px" 
                        CssClass="inputtxtControl" 
                        TabIndex="44"
                        Enabled="false">
                    </asp:TextBox>
                    <asp:Label ID="lblPlugbackTVDUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 102; left: 249px; top: 8px" 
                        CssClass="label"/>
                    <asp:Panel ID="pnlPlugbackTVDUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlPlugbackTVDUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false" 
                            Style="left: 332px; top: 6px; position: absolute; z-index: 103;" 
                            TabIndex="45"
                            Width="98">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
                <asp:Panel ID="pnlMaxTVD" 
                    runat="server" 
                    Height="30px" 
                    Width="455px" 
                    Style="left: 2px; top: 308px; z-index: 104;" 
                    CssClass="panel2">
                    <asp:Label ID="lblMaxTVD" 
                        runat="server" 
                        Text="Max TVD:" 
                        Style="z-index: 104; left: 4px; top: 8px" 
                        CssClass="label"/>
                    <asp:TextBox ID="txtMaxTVD" 
                        runat="server" 
                        Style="z-index: 101; left: 110px; top: 6px; text-align:right;" 
                        Width="122px" 
                        CssClass="inputtxtControl" 
                        TabIndex="46"
                        Enabled="false">
                    </asp:TextBox>
                    <asp:Label ID="lblMaxTVDUnits" 
                        runat="server" 
                        Text="Original Units:" 
                        Style="z-index: 102; left: 249px; top: 8px" 
                        CssClass="label"/>
                    <asp:Panel ID="pnlMaxTVDUnits"
                        runat="server" >
                        <ComponentArt:ComboBox ID="ddlMaxTVDUnits" 
                            runat="server" 
                            RunningMode="Client" 
                            AutoComplete="true"
                            AutoFilter="true"
                            AutoHighlight="true"
                            AutoTheming="true" 
                            DropDownHeight="50"
                            DropDownPageSize="2"
                            Enabled="false" 
                            Style="left: 332px; top: 6px; position: absolute; z-index: 103;" 
                            TabIndex="47"
                            Width="98">
                            <Items>
                                <ComponentArt:ComboBoxItem Text="FT" Value="FT"/>
                                <ComponentArt:ComboBoxItem Text="M" Value="M"/>
                            </Items>
                            <ClientEvents>
                                <Collapse EventHandler="ddlCollapse"/>
                            </ClientEvents>
                        </ComponentArt:ComboBox>
                    </asp:Panel>
                </asp:Panel>
            </ComponentArt:PageView>
        </PageViews>
    </ComponentArt:MultiPage>
    <asp:Button ID="btnSave"
        runat="server" 
        Height="25px" 
        Style="left: 350px; position: absolute; top: 540px; z-index: 104;"
        TabIndex="48" 
        Text="Save"
        Width="120px"/>
    <asp:Button ID="btnCancel" 
        runat="server" 
        Height="25px"
        Style="left: 485px; position: absolute; top: 540px; z-index: 105;" 
        TabIndex="49"
        Text="Cancel" 
        Width="120px"/>
</asp:Content>
