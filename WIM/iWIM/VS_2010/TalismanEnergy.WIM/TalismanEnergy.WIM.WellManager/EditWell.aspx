<%@ Page Language="vb"
         AutoEventWireup="false"
         MasterPageFile="~/WellVersionDetail.Master"
         CodeBehind="EditWell.aspx.vb"
         Inherits="TalismanEnergy.WIM.iWIM.EditWell" 
         title="iWIM - Edit Version" %>
<%@ MasterType TypeName="TalismanEnergy.WIM.iWIM.WellVersionDetail"%>
<%@ Register Assembly="ComponentArt.Web.UI"
             Namespace="ComponentArt.Web.UI"
             TagPrefix="ComponentArt" %>

<asp:Content ID="SubTitle" 
             ContentPlaceHolderID="SubTitleContent" 
             runat="server">
    Edit Version
</asp:Content>

<asp:Content ID="Actions" 
             ContentPlaceHolderID="ActionsContent" 
             runat="server">
    <asp:Button ID="btnSave"
        runat="server" 
        CssClass="actionButton"
        Text="Save"/>
    <asp:Button ID="btnCancel" 
        runat="server" 
        CssClass="actionButton"
        Text="Cancel"/>
    <div class="modal"></div>
    <script type="text/javascript">
    $(document).ready(function()
    {
        $("#<%=btnSave.ClientID%>").click(function()
        { $("body").addClass("saving"); });
    });
    </script>
</asp:Content>