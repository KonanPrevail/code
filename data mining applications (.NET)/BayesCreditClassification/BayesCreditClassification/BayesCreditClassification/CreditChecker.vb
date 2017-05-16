Imports numl.Model
Imports System
Imports System.IO
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Imports numl.Supervised.NaiveBayes
Public Class CreditChecker
    ' Only 5 attributes selected
    Public TrainingData As New List(Of Applicant)
    Public oCheckingAccount As New List(Of String)
    Public oCreditHistory As New List(Of String)
    Public oPresentEmployment As New List(Of String)
    Public oJob As New List(Of String)
    Public oForeigner As New List(Of String)
    Dim ApplicantDescriptor As Descriptor
    Dim BayesGenerator
    Dim BayesModel
    Dim fileLineContents = ""
    Dim ApplicantAttributes
    Dim oApplicant As Applicant

    Public Sub LoadData(ByVal trainingDataFile As String)
        If Not File.Exists(trainingDataFile) Then
            Throw New FileNotFoundException()
        End If
        Using fileReader As StreamReader = New StreamReader(New FileStream(trainingDataFile, FileMode.Open))
            fileLineContents = fileReader.ReadLine()
            Do Until fileLineContents Is Nothing
                ApplicantAttributes = fileLineContents.Split(" "c)
                oApplicant = New Applicant()

                oApplicant.CheckingAccount = ApplicantAttributes(0)
                oApplicant.CreditHistory = ApplicantAttributes(2)
                oApplicant.PresentEmployment = ApplicantAttributes(6)
                oApplicant.Job = ApplicantAttributes(16)
                oApplicant.Foreigner = ApplicantAttributes(19)

                If ApplicantAttributes(20) = 1 Then
                    oApplicant.CreditClass = Applicant.CreditTypes.Good
                Else
                    oApplicant.CreditClass = Applicant.CreditTypes.Bad
                End If
                TrainingData.Add(oApplicant)
                fileLineContents = fileReader.ReadLine()
            Loop
        End Using
    End Sub

    Private Sub btnRun_Click(sender As Object, e As EventArgs) Handles btnRun.Click
        Dim oTestApplicant = New Applicant()
        With oTestApplicant
            .CheckingAccount = oCheckingAccount(cboCheckingAccount.SelectedIndex)
            .CreditHistory = oCreditHistory(cboCreditHistory.SelectedIndex)
            .PresentEmployment = oPresentEmployment(cboPresentEmployment.SelectedIndex)
            .Job = oJob(cboJob.SelectedIndex)
            .Foreigner = oForeigner(cboForeigner.SelectedIndex)
        End With

        Dim iDecision = BayesModel.Predict(oTestApplicant)
        If iDecision.CreditClass = Applicant.CreditTypes.Good Then
            lblResult.Text = "Result: Approved"
        Else
            lblResult.Text = "Result: Disapproved"
        End If
    End Sub

    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        cboCheckingAccount.Items.Add("< 0")
        cboCheckingAccount.Items.Add("0 <= ... < 200 DM")
        cboCheckingAccount.Items.Add(">= 200")
        cboCheckingAccount.Items.Add("no checking account")
        cboCheckingAccount.SelectedIndex = 1
        oCheckingAccount.Add("A11")
        oCheckingAccount.Add("A12")
        oCheckingAccount.Add("A13")
        oCheckingAccount.Add("A14")

        cboCreditHistory.Items.Add("no credits taken/ all credits paid back duly")
        cboCreditHistory.Items.Add("all credits at this bank paid back duly ")
        cboCreditHistory.Items.Add("existing credits paid back duly till now")
        cboCreditHistory.Items.Add("delay in paying off in the past")
        cboCreditHistory.Items.Add("critical account/ other credits existing (not at this bank)")
        cboCreditHistory.SelectedIndex = 1
        oCreditHistory.Add("A30")
        oCreditHistory.Add("A31")
        oCreditHistory.Add("A32")
        oCreditHistory.Add("A33")
        oCreditHistory.Add("A34")

        cboPresentEmployment.Items.Add("unemployed")
        cboPresentEmployment.Items.Add("< 1 year")
        cboPresentEmployment.Items.Add("1 <= ... < 4 years")
        cboPresentEmployment.Items.Add("4 <= ... < 7 years")
        cboPresentEmployment.Items.Add("... >= 7 years")
        cboPresentEmployment.SelectedIndex = 1
        oPresentEmployment.Add("A91")
        oPresentEmployment.Add("A92")
        oPresentEmployment.Add("A93")
        oPresentEmployment.Add("A94")
        oPresentEmployment.Add("A95")

        cboJob.Items.Add("unemployed/ unskilled - non-resident")
        cboJob.Items.Add("unskilled - resident")
        cboJob.Items.Add("skilled employee / official")
        cboJob.Items.Add("management/ self-employed/highly qualified employee/ officer")
        cboJob.SelectedIndex = 1
        oJob.Add("A171")
        oJob.Add("A172")
        oJob.Add("A173")
        oJob.Add("A174")

        cboForeigner.Items.Add("yes")
        cboForeigner.Items.Add("no")
        cboForeigner.SelectedIndex = 1
        oForeigner.Add("A201")
        oForeigner.Add("A202")

        ApplicantDescriptor = Descriptor.Create(Of Applicant)()
        BayesGenerator = New NaiveBayesGenerator(1)

        LoadData("C:\Users\MC\Documents\gcredit.txt")
        BayesModel = BayesGenerator.Generate(TrainingData)
    End Sub

End Class
