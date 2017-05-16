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
        Me.lblResult = New System.Windows.Forms.Label()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.cboForeigner = New System.Windows.Forms.ComboBox()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.cboJob = New System.Windows.Forms.ComboBox()
        Me.cboPresentEmployment = New System.Windows.Forms.ComboBox()
        Me.cboCreditHistory = New System.Windows.Forms.ComboBox()
        Me.cboCheckingAccount = New System.Windows.Forms.ComboBox()
        Me.btnRun = New System.Windows.Forms.Button()
        Me.SuspendLayout()
        '
        'lblResult
        '
        Me.lblResult.AutoSize = True
        Me.lblResult.Location = New System.Drawing.Point(302, 137)
        Me.lblResult.Name = "lblResult"
        Me.lblResult.Size = New System.Drawing.Size(37, 13)
        Me.lblResult.TabIndex = 23
        Me.lblResult.Text = "Result"
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Location = New System.Drawing.Point(93, 137)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(51, 13)
        Me.Label5.TabIndex = 22
        Me.Label5.Text = "Foreigner"
        '
        'cboForeigner
        '
        Me.cboForeigner.FormattingEnabled = True
        Me.cboForeigner.Location = New System.Drawing.Point(150, 134)
        Me.cboForeigner.Name = "cboForeigner"
        Me.cboForeigner.Size = New System.Drawing.Size(121, 21)
        Me.cboForeigner.TabIndex = 21
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Location = New System.Drawing.Point(120, 110)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(24, 13)
        Me.Label4.TabIndex = 20
        Me.Label4.Text = "Job"
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(13, 83)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(131, 13)
        Me.Label3.TabIndex = 19
        Me.Label3.Text = "Present Employment since"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(75, 56)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(69, 13)
        Me.Label2.TabIndex = 18
        Me.Label2.Text = "Credit History"
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(49, 26)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(95, 13)
        Me.Label1.TabIndex = 17
        Me.Label1.Text = "Checking Account"
        '
        'cboJob
        '
        Me.cboJob.FormattingEnabled = True
        Me.cboJob.Location = New System.Drawing.Point(150, 107)
        Me.cboJob.Name = "cboJob"
        Me.cboJob.Size = New System.Drawing.Size(121, 21)
        Me.cboJob.TabIndex = 16
        '
        'cboPresentEmployment
        '
        Me.cboPresentEmployment.FormattingEnabled = True
        Me.cboPresentEmployment.Location = New System.Drawing.Point(150, 80)
        Me.cboPresentEmployment.Name = "cboPresentEmployment"
        Me.cboPresentEmployment.Size = New System.Drawing.Size(121, 21)
        Me.cboPresentEmployment.TabIndex = 15
        '
        'cboCreditHistory
        '
        Me.cboCreditHistory.FormattingEnabled = True
        Me.cboCreditHistory.Location = New System.Drawing.Point(150, 53)
        Me.cboCreditHistory.Name = "cboCreditHistory"
        Me.cboCreditHistory.Size = New System.Drawing.Size(189, 21)
        Me.cboCreditHistory.TabIndex = 14
        '
        'cboCheckingAccount
        '
        Me.cboCheckingAccount.FormattingEnabled = True
        Me.cboCheckingAccount.Location = New System.Drawing.Point(150, 26)
        Me.cboCheckingAccount.Name = "cboCheckingAccount"
        Me.cboCheckingAccount.Size = New System.Drawing.Size(189, 21)
        Me.cboCheckingAccount.TabIndex = 13
        '
        'btnRun
        '
        Me.btnRun.Location = New System.Drawing.Point(444, 52)
        Me.btnRun.Name = "btnRun"
        Me.btnRun.Size = New System.Drawing.Size(75, 23)
        Me.btnRun.TabIndex = 12
        Me.btnRun.Text = "Run"
        Me.btnRun.UseVisualStyleBackColor = True
        '
        'frmBayesClassification
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(538, 191)
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
        Me.Name = "frmBayesClassification"
        Me.Text = "Credit Card Application "
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lblResult As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents cboForeigner As System.Windows.Forms.ComboBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cboJob As System.Windows.Forms.ComboBox
    Friend WithEvents cboPresentEmployment As System.Windows.Forms.ComboBox
    Friend WithEvents cboCreditHistory As System.Windows.Forms.ComboBox
    Friend WithEvents cboCheckingAccount As System.Windows.Forms.ComboBox
    Friend WithEvents btnRun As System.Windows.Forms.Button

End Class
