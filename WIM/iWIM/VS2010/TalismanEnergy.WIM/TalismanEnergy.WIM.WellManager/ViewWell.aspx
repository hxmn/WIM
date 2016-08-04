<%@ Page Language="vb"
         AutoEventWireup="false"
         MasterPageFile="~/WellVersionDetail.Master"
         CodeBehind="ViewWell.aspx.vb"
         Inherits="TalismanEnergy.WIM.iWIM.ViewWell" 
         title="iWIM - View Version" %>
<%@ MasterType TypeName="TalismanEnergy.WIM.iWIM.WellVersionDetail"%>
<%@ Register Assembly="ComponentArt.Web.UI"
             Namespace="ComponentArt.Web.UI"
             TagPrefix="ComponentArt" %>

<asp:Content ID="SubTitle" 
             ContentPlaceHolderID="SubTitleContent" 
             runat="server">
    View Version
</asp:Content>

<asp:Content ID="Actions" 
             ContentPlaceHolderID="ActionsContent" 
             runat="server">
    <asp:Button ID="btnDone"
        runat="server" 
        CssClass="actionButton"
        Text="Done"/>
    <div class="modal"></div>
    <script type="text/javascript">
    </script>
</asp:Content>
