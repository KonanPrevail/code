Public Class CreditCardProcessing
    Private Sub ProcessPayment()
        Dim MerchantInfo As New PaymentProcessors.AuthorizeDotNet.MerchantInfo
        Dim OrderInfo As New PaymentProcessors.AuthorizeDotNet.OrderInfo
        Dim Results As New PaymentProcessors.AuthorizeDotNet.Output

        ' American Express Test Card: 370000000000002
        ' Discover Test Card: 6011000000000012
        ' Visa Test Card: 4007000000027 
        ' Second Visa Test Card: 4012888818888 or 4222222222222222
        ' JCB: 3088000000000017
        ' Diners Club/ Carte Blanche: 38000000000006
        ' MC: 5555555555554444 or 5105105105105100:

        ' Need to create a free sandbox account on Authorize.net
        With MerchantInfo
            .AuthNetVersion = "3.1"
            .MerchantEmail = "xx@gmail.com"
            .AuthNetLoginId = "xx"
            .AuthNetTransKey = "xx"
        End With
        Dim strHostName = System.Net.Dns.GetHostName()
        Dim strIPAddress = System.Net.Dns.GetHostEntry(strHostName).AddressList(0).ToString()
        With OrderInfo
            .FirstName = Me.txtContactFirstName.Text
            .LastName = Me.txtContactLastName.Text
            .Phone = Me.txtPhone.Text
            .Address = Me.txtAddress1.Text
            .City = txtCity.Text
            .State = txtState.Text
            .ZipCode = txtZipCode.Text
            .Email = txtEmail.Text
            .Country = "US"
            .Amount = txtAmount.Text
            .Description = txtDescription.Text
            .CreditCardNumber = txtCreditCardNumber.Text
            .ExpireDate = txtExpireDate.Text
            .IPNumber = strIPAddress '"137.99.88.88" 
            .SecurityCode = txtSecurityCode.Text
        End With

        Results = PaymentProcessors.AuthorizeDotNet.ProcessPayment(MerchantInfo, OrderInfo)
        If Results.HasError = True Then
            MessageBox.Show(Results.ErrorMessage)
        Else
            MessageBox.Show(Now.ToString & ": SUCCESS!" & vbCrLf & "Auth:" & Results.AuthorizationCode & vbCrLf & "ID:" & Results.TransactionId)
        End If

    End Sub

    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        txtCreditCardNumber.Text = "4111111111111111"
        txtSecurityCode.Text = "111"
        txtExpireDate.Text = "1/1/2020"
        txtState.Text = "CT"
        txtCity.Text = "Mansfield"
        txtAmount.Text = "1.00"
        txtContactFirstName.Text = "John"
        txtContactLastName.Text = "Doe"
        txtAddress1.Text = "1111 Test road"
        txtDescription.Text = "For testing"
        txtExpireDate.Text = "1/1/2020"
        txtZipCode.Text = "06268"
        txtPhone.Text = "860860860"
        txtEmail.Text = "testemail@gmail.com"
    End Sub

    Private Sub btnExit_Click(sender As Object, e As EventArgs) Handles btnExit.Click
        End
    End Sub

    Private Sub btnSubmit_Click(sender As Object, e As EventArgs) Handles btnSubmit.Click
        ProcessPayment()
    End Sub
End Class
