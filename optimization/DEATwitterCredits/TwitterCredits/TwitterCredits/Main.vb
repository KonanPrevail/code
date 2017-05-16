Imports Microsoft.Office.Interop.Excel
Imports Microsoft.SolverFoundation.Solvers
Imports Microsoft.SolverFoundation.Common
Public Class frmTwitterProfileAcquisition
    Dim oHtml As HtmlDocument
    Dim oDiv As HtmlElementCollection
    Dim oSpan As HtmlElementCollection
    Dim oAll As HtmlElementCollection
    Dim oTweets As New List(Of KeyValuePair(Of String, String))
    Dim oExcel As Application
    Dim oWB As Workbook
    Dim oWS As Worksheet
    Dim oRange As Range
    Dim solver As SimplexSolver
    Public Sub WaitForReady(webBrowser As WebBrowser)
        Do
            System.Windows.Forms.Application.DoEvents()
        Loop Until webBrowser.IsBusy = False And webBrowser.ReadyState = WebBrowserReadyState.Complete
    End Sub

    Private Sub WebBrowser_DocumentCompleted(sender As Object, e As WebBrowserDocumentCompletedEventArgs) Handles webBrowser.DocumentCompleted
        Dim curElement As HtmlElement
        oDiv = webBrowser.Document.GetElementsByTagName("div")
        For Each curElement In oDiv
            If InStr(curElement.GetAttribute("className").ToString, "t1-form signin") Then
                webBrowser.DocumentText = curElement.InnerHtml
            End If
        Next
    End Sub

    Private Sub frmTwitterProfileAcquisition_Disposed(sender As Object, e As EventArgs) Handles Me.Disposed
        WaitForReady(webBrowser)
        webBrowser.Document.GetElementById("signout-button").InvokeMember("click")
        WaitForReady(webBrowser)
    End Sub

    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        'btnSignout.Enabled = False
        webBrowser.ScriptErrorsSuppressed = True
        webBrowser.Visible = False
        webBrowser.Navigate("www.twitter.com")
    End Sub

    Private Sub btnSignin_Click(sender As Object, e As EventArgs) Handles btnSignin.Click
        WaitForReady(webBrowser)
        webBrowser.Document.GetElementById("signin-email").SetAttribute("value", txtEmail.Text)
        webBrowser.Document.GetElementById("signin-password").SetAttribute("value", txtPassword.Text)
        webBrowser.Document.Forms(2).InvokeMember("submit")
        WaitForReady(webBrowser)
        If webBrowser.Document.Title.ToLower.Contains("login on twitter") Then
            MsgBox("Can not log in")
        Else
            txtEmail.Enabled = False
            txtPassword.Enabled = False
            btnSignin.Enabled = False
            btnSignout.Enabled = True
        End If
    End Sub

    Private Sub btnGetData_Click(sender As Object, e As EventArgs) Handles btnGetData.Click
        Dim curElement As HtmlElement
        Dim frmProfile As New Profile
        Dim i As Integer = 0
        Dim strParams() As String

        webBrowser.Navigate(txtLink.Text)
        WaitForReady(webBrowser)
        oSpan = webBrowser.Document.GetElementsByTagName("a")
        For Each curElement In oSpan
            If InStr(curElement.GetAttribute("className").ToString, "ProfileNav-stat ProfileNav-stat--link u-borderUserColor u-textCenter js-tooltip js-nav") > 0 _
                Or InStr(curElement.GetAttribute("className").ToString, "ProfileNav-stat ProfileNav-stat--link u-borderUserColor u-textCenter js-tooltip js-nav u-textUserColor") > 0 _
                Or InStr(curElement.GetAttribute("className").ToString, "ProfileNav-stat ProfileNav-stat--link u-borderUserColor u-textCenter js-tooltip js-nav u-textUserColor") > 0 Then
                strParams = curElement.InnerText.Trim.Replace(vbCrLf, " ").Replace("  ", " ").Split(" ")
                oTweets.Add(New KeyValuePair(Of String, String)(strParams(0), strParams(1)))
            End If
        Next

        Dim deaScore = ComputeDEA(oTweets)

        frmProfile.Show()
        frmProfile.lblTweetNum.Text = frmProfile.lblTweetNum.Text + ": " + oTweets.Item(0).Value
        frmProfile.lblFollowingNum.Text = frmProfile.lblFollowingNum.Text + ": " + oTweets.Item(1).Value
        frmProfile.lblFollowerNum.Text = frmProfile.lblFollowerNum.Text + ": " + oTweets.Item(2).Value

        frmProfile.lblScore.Text = "Score: " & deaScore
        
    End Sub

    Private Sub btnSignout_Click(sender As Object, e As EventArgs) Handles btnSignout.Click
        WaitForReady(webBrowser)
        webBrowser.Document.GetElementById("signout-button").InvokeMember("click")
        btnSignin.Enabled = True
        btnSignout.Enabled = False
    End Sub

    Private Sub btnExit_Click(sender As Object, e As EventArgs) Handles btnExit.Click
        WaitForReady(webBrowser)
        webBrowser.Document.GetElementById("signout-button").InvokeMember("click")
        WaitForReady(webBrowser)
        End
    End Sub

    Private Sub btnScore_Click(sender As Object, e As EventArgs) Handles btnScore.Click
        ComputeDEA()
    End Sub
    Private Overloads Function ComputeDEA(oTweets As List(Of KeyValuePair(Of String, String))) As Double
        'https://msdn.microsoft.com/en-us/library/ff628587(v=vs.93).aspx
        'https://msdn.microsoft.com/en-us/library/ff713958(v=vs.93).aspx
        Dim dlgOpen As New OpenFileDialog
        Dim iDMU As Integer
        Dim iTweetUnitCost As Integer, iFollowingUnitCost As Integer, iFollowerUnitPrice As Integer
        Dim iModelRowId As Integer
        Dim deaScore As Double = 0
        If dlgOpen.ShowDialog() = System.Windows.Forms.DialogResult.OK Then
            oExcel = New Application()
            oWB = oExcel.Workbooks.Open(dlgOpen.FileName)
            Dim found As Boolean = False
            For Each ws In oWB.Worksheets
                If ws.Name = "Twitter" Then
                    found = True
                End If
            Next
            If Not found Then
                Return -1
                Exit Function

            Else
                oWS = oWB.Worksheets("Twitter")
                oRange = oWS.UsedRange

                oWS.Range("A1").Offset(oRange.Rows.Count, 0).Value = txtLink.Text
                oWS.Range("A1").Offset(oRange.Rows.Count, 1).Value = "Profile" & (oRange.Rows.Count).ToString
                oWS.Range("A1").Offset(oRange.Rows.Count, 2).Value = oTweets.Item(0).Value
                oWS.Range("A1").Offset(oRange.Rows.Count, 3).Value = oTweets.Item(1).Value
                oWS.Range("A1").Offset(oRange.Rows.Count, 4).Value = oTweets.Item(2).Value


                oWS.Range("A1").Offset(0, 6).Value = "Tweet Unit Cost"
                oWS.Range("A1").Offset(0, 7).Value = "Following Unit Cost"
                oWS.Range("A1").Offset(0, 8).Value = "Follower Unit Price"
                oWS.Range("A1").Offset(0, 9).Value = "Score"

                For iDMU = 1 To oRange.Rows.Count - 1
                    solver = New SimplexSolver()
                    solver.AddVariable("TweetCost", iTweetUnitCost)
                    solver.SetBounds(iTweetUnitCost, 0, Rational.PositiveInfinity)
                    solver.AddVariable("FollowingCost", iFollowingUnitCost)
                    solver.SetBounds(iFollowingUnitCost, 0, Rational.PositiveInfinity)
                    solver.AddVariable("FollowerPrice", iFollowerUnitPrice)
                    solver.SetBounds(iFollowerUnitPrice, 0, Rational.PositiveInfinity)

                    For iConstraint = 1 To oRange.Rows.Count - 1
                        solver.AddRow(oWS.Range("A1").Offset(iConstraint, 1), iModelRowId)
                        solver.SetCoefficient(iModelRowId, iTweetUnitCost, -1 * CType(oWS.Range("A1").Offset(iConstraint, 2).Value.ToString, Rational))
                        solver.SetCoefficient(iModelRowId, iFollowingUnitCost, -1 * CType(oWS.Range("A1").Offset(iConstraint, 3).Value.ToString, Rational))
                        solver.SetCoefficient(iModelRowId, iFollowerUnitPrice, CType(oWS.Range("A1").Offset(iConstraint, 4).Value.ToString, Rational))
                        solver.SetBounds(iModelRowId, Rational.NegativeInfinity, 0)
                    Next

                    solver.AddRow(oWS.Range("A1").Offset(iDMU, 1), iModelRowId)
                    solver.SetCoefficient(iModelRowId, iTweetUnitCost, CType(oWS.Range("A1").Offset(iDMU, 2).Value.ToString, Rational))
                    solver.SetCoefficient(iModelRowId, iFollowingUnitCost, CType(oWS.Range("A1").Offset(iDMU, 3).Value.ToString, Rational))
                    solver.SetBounds(iModelRowId, 1, 1)

                    solver.AddRow("Objective", iModelRowId)
                    solver.SetCoefficient(iModelRowId, iFollowerUnitPrice, CType(oWS.Range("A1").Offset(iDMU, 4).Value.ToString, Rational))
                    solver.AddGoal(iModelRowId, 0, False)
                    solver.Solve(New SimplexSolverParams())
                Next
                oWS.Range("A1").Offset(iDMU, 6).Value = solver.GetValue(iTweetUnitCost).ToDouble()
                oWS.Range("A1").Offset(iDMU, 7).Value = solver.GetValue(iFollowingUnitCost).ToDouble()
                oWS.Range("A1").Offset(iDMU, 8).Value = solver.GetValue(iFollowerUnitPrice).ToDouble()
                oWS.Range("A1").Offset(iDMU, 9).Value = solver.GetValue(iFollowerUnitPrice).ToDouble() * oWS.Range("A1").Offset(iDMU, 4).Value
                deaScore = solver.GetValue(iFollowerUnitPrice).ToDouble() * oWS.Range("A1").Offset(iDMU, 4).Value
                oWB.Save()
                oWB.Close()
                oExcel.Quit()
            End If
        End If
        Return deaScore
        'MsgBox("Done")
    End Function
    Private Overloads Function ComputeDEA() As Double
        'https://msdn.microsoft.com/en-us/library/ff628587(v=vs.93).aspx
        'https://msdn.microsoft.com/en-us/library/ff713958(v=vs.93).aspx
        Dim dlgOpen As New OpenFileDialog
        Dim iDMU As Integer
        Dim iTweetUnitCost As Integer, iFollowingUnitCost As Integer, iFollowerUnitPrice As Integer
        Dim iModelRowId As Integer
        Dim deaScore As Double = 0
        If dlgOpen.ShowDialog() = System.Windows.Forms.DialogResult.OK Then
            oExcel = New Application()
            oWB = oExcel.Workbooks.Open(dlgOpen.FileName)
            Dim found As Boolean = False
            For Each ws In oWB.Worksheets
                If ws.Name = "Twitter" Then
                    found = True
                End If
            Next
            If Not found Then
                Return -1
                Exit Function

            Else
                oWS = oWB.Worksheets("Twitter")
                oRange = oWS.UsedRange

                oWS.Range("A1").Offset(0, 6).Value = "Tweet Unit Cost"
                oWS.Range("A1").Offset(0, 7).Value = "Following Unit Cost"
                oWS.Range("A1").Offset(0, 8).Value = "Follower Unit Price"
                oWS.Range("A1").Offset(0, 9).Value = "Score"

                For iDMU = 1 To oRange.Rows.Count - 1
                    solver = New SimplexSolver()
                    solver.AddVariable("TweetCost", iTweetUnitCost)
                    solver.SetBounds(iTweetUnitCost, 0, Rational.PositiveInfinity)
                    solver.AddVariable("FollowingCost", iFollowingUnitCost)
                    solver.SetBounds(iFollowingUnitCost, 0, Rational.PositiveInfinity)
                    solver.AddVariable("FollowerPrice", iFollowerUnitPrice)
                    solver.SetBounds(iFollowerUnitPrice, 0, Rational.PositiveInfinity)

                    For iConstraint = 1 To oRange.Rows.Count - 1
                        solver.AddRow(oWS.Range("A1").Offset(iConstraint, 1), iModelRowId)
                        solver.SetCoefficient(iModelRowId, iTweetUnitCost, -1 * CType(oWS.Range("A1").Offset(iConstraint, 2).Value.ToString, Rational))
                        solver.SetCoefficient(iModelRowId, iFollowingUnitCost, -1 * CType(oWS.Range("A1").Offset(iConstraint, 3).Value.ToString, Rational))
                        solver.SetCoefficient(iModelRowId, iFollowerUnitPrice, CType(oWS.Range("A1").Offset(iConstraint, 4).Value.ToString, Rational))
                        solver.SetBounds(iModelRowId, Rational.NegativeInfinity, 0)
                    Next

                    solver.AddRow(oWS.Range("A1").Offset(iDMU, 1), iModelRowId)
                    solver.SetCoefficient(iModelRowId, iTweetUnitCost, CType(oWS.Range("A1").Offset(iDMU, 2).Value.ToString, Rational))
                    solver.SetCoefficient(iModelRowId, iFollowingUnitCost, CType(oWS.Range("A1").Offset(iDMU, 3).Value.ToString, Rational))
                    solver.SetBounds(iModelRowId, 1, 1)

                    solver.AddRow("Objective", iModelRowId)
                    solver.SetCoefficient(iModelRowId, iFollowerUnitPrice, CType(oWS.Range("A1").Offset(iDMU, 4).Value.ToString, Rational))
                    solver.AddGoal(iModelRowId, 0, False)
                    solver.Solve(New SimplexSolverParams())

                    oWS.Range("A1").Offset(iDMU, 6).Value = solver.GetValue(iTweetUnitCost).ToDouble()
                    oWS.Range("A1").Offset(iDMU, 7).Value = solver.GetValue(iFollowingUnitCost).ToDouble()
                    oWS.Range("A1").Offset(iDMU, 8).Value = solver.GetValue(iFollowerUnitPrice).ToDouble()
                    oWS.Range("A1").Offset(iDMU, 9).Value = solver.GetValue(iFollowerUnitPrice).ToDouble() * oWS.Range("A1").Offset(iDMU, 4).Value
                Next
                oWB.Save()
                oWB.Close()
                oExcel.Quit()
            End If
        End If
        MsgBox("Done")
        Return -1
    End Function
End Class
