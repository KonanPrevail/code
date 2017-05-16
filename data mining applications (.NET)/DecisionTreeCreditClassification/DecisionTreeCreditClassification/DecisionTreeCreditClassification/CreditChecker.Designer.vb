<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class CreditChecker
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.btnRun = New System.Windows.Forms.Button()
        Me.cboCheckingAccount = New System.Windows.Forms.ComboBox()
        Me.cboCreditHistory = New System.Windows.Forms.ComboBox()
        Me.cboPresentEmployment = New System.Windows.Forms.ComboBox()
        Me.cboJob = New System.Windows.Forms.ComboBox()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.cboForeigner = New System.Windows.Forms.ComboBox()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.lblResult = New System.Windows.Forms.Label()
        Me.SuspendLayout()
        '
        'btnRun
        '
        Me.btnRun.Location = New System.Drawing.Point(445, 50)
        Me.btnRun.Name = "btnRun"
        Me.btnRun.Size = New System.Drawing.Size(75, 23)
        Me.btnRun.TabIndex = 0
        Me.btnRun.Text = "Run"
        Me.btnRun.UseVisualStyleBackColor = True
        '
        'cboCheckingAccount
        '
        Me.cboCheckingAccount.FormattingEnabled = True
        Me.cboCheckingAccount.Location = New System.Drawing.Point(151, 24)
        Me.cboCheckingAccount.Name = "cboCheckingAccount"
        Me.cboCheckingAccount.Size = New System.Drawing.Size(189, 21)
        Me.cboCheckingAccount.TabIndex = 1
        '
        'cboCreditHistory
        '
        Me.cboCreditHistory.FormattingEnabled = True
        Me.cboCreditHistory.Location = New System.Drawing.Point(151, 51)
        Me.cboCreditHistory.Name = "cboCreditHistory"
        Me.cboCreditHistory.Size = New System.Drawing.Size(189, 21)
        Me.cboCreditHistory.TabIndex = 2
        '
        'cboPresentEmployment
        '
        Me.cboPresentEmployment.FormattingEnabled = True
        Me.cboPresentEmployment.Location = New System.Drawing.Point(151, 78)
        Me.cboPresentEmployment.Name = "cboPresentEmployment"
        Me.cboPresentEmployment.Size = New System.Drawing.Size(121, 21)
        Me.cboPresentEmployment.TabIndex = 3
        '
        'cboJob
        '
        Me.cboJob.FormattingEnabled = True
        Me.cboJob.Location = New System.Drawing.Point(151, 105)
        Me.cboJob.Name = "cboJob"
        Me.cboJob.Size = New System.Drawing.Size(121, 21)
        Me.cboJob.TabIndex = 4
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(50, 24)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(95, 13)
        Me.Label1.TabIndex = 5
        Me.Label1.Text = "Checking Account"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(76, 54)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(69, 13)
        Me.Label2.TabIndex = 6
        Me.Label2.Text = "Credit History"
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(14, 81)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(131, 13)
        Me.Label3.TabIndex = 7
        Me.Label3.Text = "Present Employment since"
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Location = New System.Drawing.Point(121, 108)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(24, 13)
        Me.Label4.TabIndex = 8
        Me.Label4.Text = "Job"
        '
        'cboForeigner
        '
        Me.cboForeigner.FormattingEnabled = True
        Me.cboForeigner.Location = New System.Drawing.Point(151, 132)
        Me.cboForeigner.Name = "cboForeigner"
        Me.cboForeigner.Size = New System.Drawing.Size(121, 21)
        Me.cboForeigner.TabIndex = 9
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Location = New System.Drawing.Point(94, 135)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(51, 13)
        Me.Label5.TabIndex = 10
        Me.Label5.Text = "Foreigner"
        '
        'lblResult
        '
        Me.lblResult.AutoSize = True
        Me.lblResult.Location = New System.Drawing.Point(303, 135)
        Me.lblResult.Name = "lblResult"
        Me.lblResult.Size = New System.Drawing.Size(37, 13)
        Me.lblResult.TabIndex = 11
        Me.lblResult.Text = "Result"
        '
        'CreditChecker
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(569, 192)
        Me.Controls.Add(Me.lblResult)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.cboForeigner)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.cboJob)
        Me.Controls.Add(Me.cboPresentEmployment)
        Me.Controls.Add(Me.cboCreditHistory)
        Me.Controls.Add(Me.cboCheckingAccount)
        Me.Controls.Add(Me.btnRun)
        Me.Name = "CreditChecker"
        Me.Text = "Credit Checker"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents btnRun As System.Windows.Forms.Button
    Friend WithEvents cboCheckingAccount As System.Windows.Forms.ComboBox
    Friend WithEvents cboCreditHistory As System.Windows.Forms.ComboBox
    Friend WithEvents cboPresentEmployment As System.Windows.Forms.ComboBox
    Friend WithEvents cboJob As System.Windows.Forms.ComboBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents cboForeigner As System.Windows.Forms.ComboBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents lblResult As System.Windows.Forms.Label

End Class
