<%@ Page Language="vb"
         AutoEventWireup="false"
         MasterPageFile="~/WellVersionDetail.Master"
         CodeBehind="AddVersion.aspx.vb"
         Inherits="TalismanEnergy.WIM.iWIM.AddVersion" 
         title="iWIM - Add Version"%>
<%@ MasterType TypeName="TalismanEnergy.WIM.iWIM.WellVersionDetail"%>
<%@ Register Assembly="ComponentArt.Web.UI"
             Namespace="ComponentArt.Web.UI"
             TagPrefix="ComponentArt" %>
             
<asp:Content ID="SubTitle" 
             ContentPlaceHolderID="SubTitleContent" 
             runat="server">
    Add Version
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
      // KLUDGE ALERT!
      // This exists to prevent a NullReferenceException being caused
      // intrermittently in the ComponentArt ComboBoxes that have a dynamic model
      // Seems to work?!?!
      function cleanDynComboBox(ddl) {
        selItem = ddl.getSelectedItem();
        if (selItem != null) {
          ddl.removeAll();
          selItem.SetProperty("Index", 0);
          ddl.addItem(selItem, 0);
          ddl.selectItem(selItem);
        }
      }

      $(document).ready(function () {
        $("#<%=btnSave.ClientID%>").click(function () {
          cleanDynComboBox(window.ddlOperator);
          cleanDynComboBox(window.ddlLicensee);
          $("body").addClass("saving");
        });
      });
    </script>
</asp:Content>
