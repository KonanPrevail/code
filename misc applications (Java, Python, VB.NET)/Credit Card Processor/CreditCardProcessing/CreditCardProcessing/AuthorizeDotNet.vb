' From https://c2it.wordpress.com/2011/08/24/simple-credit-card-processing-using-vb-net-and-authorize-net/
Imports Microsoft.VisualBasic
Imports System
Imports System.Data
Imports System.Configuration
Imports System.Collections
Imports System.Web
Imports System.Net
Imports System.Net.Mail

Namespace PaymentProcessors
    Public Class AuthorizeDotNet
        Public Class MerchantInfo
            Public AuthNetVersion As String = "3.1" 'Contains CCV support
            Public MerchantEmail As String = ""
            Public AuthNetLoginId As String = "" 'Set AuthNetLoginId here (or in the calling routine)
            Public AuthNetTransKey As String = "" ' Get this from your authorize.net merchant interface (set it here or in the calling routine)"
        End Class

        Public Class Output
            Public AuthorizationCode As String
            Public TransactionId As String
            Public HasError As Boolean
            Public ErrorMessage As String
        End Class

        Public Class OrderInfo
            Public FirstName As String
            Public LastName As String
            Public Phone As String
            Public Address As String
            Public City As String
            Public State As String
            Public ZipCode As String
            Public Email As String
            Public Country As String
            Public Amount As Double
            Public Description As String
            Public IPNumber As String
            Public CreditCardNumber As String
            Public ExpireDate As String
            Public SecurityCode As String

        End Class

        Public Shared Function ProcessPayment(ByVal Merchant As MerchantInfo, ByVal Order As OrderInfo) As Output
            Dim rv As New Output

            Dim webClientRequest As New WebClient()
            Dim InputObject As New System.Collections.Specialized.NameValueCollection(30)
            Dim ReturnObject As New System.Collections.Specialized.NameValueCollection(30)

            Dim ReturnBytes As Byte()
            Dim ReturnValues As String()

            InputObject.Add("x_version", Merchant.AuthNetVersion)
            InputObject.Add("x_delim_data", "True")
            InputObject.Add("x_login", Merchant.AuthNetLoginId)
            InputObject.Add("x_tran_key", Merchant.AuthNetTransKey)
            InputObject.Add("x_relay_response", "False")

            'Set this to false to go live
            InputObject.Add("x_test_request", "True")

            InputObject.Add("x_delim_char", ",")
            InputObject.Add("x_encap_char", "|")

            'Billing Address
            InputObject.Add("x_first_name", Order.FirstName)
            InputObject.Add("x_last_name", Order.LastName)
            InputObject.Add("x_phone", Order.Phone)
            InputObject.Add("x_address", Order.Address)
            InputObject.Add("x_city", Order.City)
            InputObject.Add("x_state", Order.State)
            InputObject.Add("x_zip", Order.ZipCode)
            InputObject.Add("x_email", Order.Email)
            InputObject.Add("x_email_customer", "TRUE")                     'Emails Customer
            InputObject.Add("x_merchant_email", Merchant.MerchantEmail)  'Emails Merchant
            InputObject.Add("x_country", Order.Country)
            InputObject.Add("x_customer_ip", Order.IPNumber)

            'Amount
            InputObject.Add("x_description", Order.Description + ": " + String.Format("{0:c2}", Order.Amount)) 'Description of Purchase

            'Card Details
            InputObject.Add("x_card_num", Order.CreditCardNumber)
            InputObject.Add("x_exp_date", Order.ExpireDate) 'MM/DD
            InputObject.Add("x_card_code", Order.SecurityCode)

            InputObject.Add("x_method", "CC")
            InputObject.Add("x_type", "AUTH_CAPTURE")
            InputObject.Add("x_amount", String.Format("{0:c2}", Order.Amount))

            'Currency setting. Check the guide for other supported currencies
            InputObject.Add("x_currency_code", "USD")

            Try
                'Actual Server
                'Set above Testmode=off to go live
                'webClientRequest.BaseAddress = "https://secure.authorize.net/gateway/transact.dll"
                webClientRequest.BaseAddress = "https://test.authorize.net/gateway/transact.dll"

                ReturnBytes = webClientRequest.UploadValues(webClientRequest.BaseAddress, "POST", InputObject)
                ReturnValues = System.Text.Encoding.ASCII.GetString(ReturnBytes).Split(",".ToCharArray())

                If ReturnValues(0).Trim(Char.Parse("|")) = "1" Then
                    rv.AuthorizationCode = ReturnValues(4).Trim(Char.Parse("|"))
                    rv.TransactionId = ReturnValues(6).Trim(Char.Parse("|"))
                    Return rv
                Else
                    'Error!
                    rv.HasError = True
                    rv.ErrorMessage = ReturnValues(3).Trim(Char.Parse("|")) + " (" + ReturnValues(2).Trim(Char.Parse("|")) + ")"
                    If ReturnValues(2).Trim(Char.Parse("|")) = "44" Then
                        rv.ErrorMessage += "Credit Card Code Verification (CCV) returned the following error: "
                        Select Case ReturnValues(38).Trim(Char.Parse("|"))
                            Case Is = "N"
                                rv.ErrorMessage += " Card Code does not match."
                            Case Is = "P"
                                rv.ErrorMessage += " Card Code was not processed."
                            Case Is = "S"
                                rv.ErrorMessage = " Card Code should be on card but was not indicated."
                            Case Is = "U"
                                rv.ErrorMessage = " Issuer was not certified for Card Code."
                        End Select
                    End If
                    If ReturnValues(2).Trim(Char.Parse("|")) = "45" Then
                        rv.ErrorMessage += "<br/>n"

                        'AVS transaction decline
                        rv.ErrorMessage += "Address Verification System (AVS) returned the following error:"

                        Select Case ReturnValues(5).Trim(Char.Parse("|"))
                            Case Is = "A"
                                rv.ErrorMessage += " the zip code entered does not match the billing address."
                            Case Is = "B"
                                rv.ErrorMessage += " no information was provided for the AVS check."
                            Case Is = "E"
                                rv.ErrorMessage += " a general error occurred in the AVS system."
                            Case Is = "G"
                                rv.ErrorMessage += " the credit card was issued by a non-US bank."
                            Case Is = "N"
                                rv.ErrorMessage += " neither the entered street address nor zip code matches the billing address."
                            Case Is = "P"
                                rv.ErrorMessage += " AVS is not applicable for this transaction."
                            Case Is = "R"
                                rv.ErrorMessage += " please retry the transaction; the AVS system was unavailable or timed out."
                            Case Is = "S"
                                rv.ErrorMessage += " the AVS service is not supported by your credit card issuer."
                            Case Is = "U"
                                rv.ErrorMessage += " address information is unavailable for the credit card."
                            Case Is = "W"
                                rv.ErrorMessage += " the 9 digit zip code matches, but the street address does not."
                            Case Is = "Z"
                                rv.ErrorMessage += " the zip code matches, but the address does not."
                        End Select
                    End If
                End If
            Catch ex As Exception
                rv.HasError = True
                rv.ErrorMessage = ex.Message
            End Try

            Return rv
        End Function
    End Class
End Namespace