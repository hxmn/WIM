<%@ Page Language="vb"
         AutoEventWireup="false"
         MasterPageFile="~/WellVersionDetail.Master"
         CodeBehind="WellVersion.aspx.vb"
         Inherits="TalismanEnergy.WIM.iWIM.WellVersion" 
         title="iWIM - Review Well Version"%>
<%@ MasterType TypeName="TalismanEnergy.WIM.iWIM.WellVersionDetail"%>
<%@ Register Assembly="ComponentArt.Web.UI"
             Namespace="ComponentArt.Web.UI"
             TagPrefix="ComponentArt" %>
             
<asp:Content ID="SubTitle" 
             ContentPlaceHolderID="SubTitleContent" 
             runat="server">
    Review Well Version
</asp:Content>

<asp:Content ID="Actions" 
             ContentPlaceHolderID="ActionsContent" 
             runat="server">
    <asp:Button ID="btnEditVersion" 
        runat="server" 
        CssClass="actionButton"
        Enabled="true"
        Text="Edit Version"
        Visible="true"/>
    <asp:Button ID="btnAddVersion" 
        runat="server"
        CssClass="actionButton"
        Enabled="true"
        Text="Add Version"
        Visible="true"/>
</asp:Content>
