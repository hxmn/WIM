<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ErrorMessage.aspx.vb" Inherits="TalismanEnergy.WIM.iWIM.ErrorMessage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>iWIM Error</title>
    <link href="css/BlackIce.css" type="text/css" rel="stylesheet" />
    <link href="css/CArt.css" type="text/css" rel="stylesheet" />
    <link href="css/iWIM.css" type="text/css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <%--<div>
        <asp:Image ID="imgBanner" runat="server" ImageUrl="WellManagerbanner.png"
            Style="z-index: 100; left: 0px; position: absolute; top: 0px" />
    </div>--%>
    <!--
    <div id="Banner" style="z-index: 100; left: 0px; position: absolute; top: 0px; width: 100%; background-image: url(images/iWIMbannerExt.png); background-repeat:  repeat-x" >
        <asp:Image ID="Image1" runat="server" ImageUrl="~/images/iWIMbanner.png"
            Style="z-index: 101; left: 0px; position: relative; top: 0px;" />
        
    </div>
    -->
    <div id="Banner" >
      <img id="BannerImg" src="images/BannerRight64.png" alt="" />
    </div>
    <div  style=" z-index: 100;  position: absolute; top: 64px; left:0px; width: 100%; height: 30px; background-color: Window;">
          <div 
                style="z-index: 100; left: 0px; position: absolute; top: 0px; width: 100%;  vertical-align: middle;
                        min-height:40px; border:0">
            <span style=" z-index: 100;  position: absolute; top: 3px; left:3px; vertical-align: middle;">
                <asp:Button ID="ButtonHome" Text="Home" PostBackUrl="~/Default.aspx" runat="server" EnableTheming="true" Font-Bold="true" Height="25px" Width="90px" ToolTip=""/>
                <asp:Button ID="ButtonSearch" Text="Search" PostBackUrl="~/SearchWell.aspx" runat="server" EnableTheming="true" Font-Bold="true" Height="25px" Width="90px" ToolTip="Search in DataFinder"/>
                <asp:Button ID="ButtonCreate" Text="Create" PostBackUrl="~/CreateWell.aspx" runat="server" EnableTheming="true" Font-Bold="true" Height="25px" Width="90px" ToolTip="Create Well"/>
            </span>  
          </div>
    </div>
    <div style="left: 0px; position: absolute; top: 84px; width: 98%; ">
    <asp:Label ID="Label1" runat="server" Font-Bold="True" Font-Italic="False" Font-Names="Verdana"
        Height="36px" Style="left: 3px; position: absolute; top: 62px" Text="Application Error has occured with the following descriptions:"
        Width="538px" ForeColor="red"></asp:Label>
    <asp:TextBox ID="txtErrorMessage" runat="server" BackColor="LightYellow" BorderColor="Transparent"
        BorderWidth="0px" Height="337px" Style="left: 1px; position: absolute; top: 103px" 
        TextMode="MultiLine" Width="917px" Font-Italic="False" Font-Names="Verdana" Font-Size="Small" ForeColor="black"></asp:TextBox>
    </div>
    </form>
</body>
</html>
