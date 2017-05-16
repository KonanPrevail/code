<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Profile
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
        Me.lblTweetNum = New System.Windows.Forms.Label()
        Me.lblFollowerNum = New System.Windows.Forms.Label()
        Me.lblFollowingNum = New System.Windows.Forms.Label()
        Me.lblScore = New System.Windows.Forms.Label()
        Me.SuspendLayout()
        '
        'lblTweetNum
        '
        Me.lblTweetNum.AutoSize = True
        Me.lblTweetNum.Location = New System.Drawing.Point(34, 24)
        Me.lblTweetNum.Name = "lblTweetNum"
        Me.lblTweetNum.Size = New System.Drawing.Size(94, 13)
        Me.lblTweetNum.TabIndex = 0
        Me.lblTweetNum.Text = "Number of Tweets"
        '
        'lblFollowerNum
        '
        Me.lblFollowerNum.AutoSize = True
        Me.lblFollowerNum.Location = New System.Drawing.Point(34, 71)
        Me.lblFollowerNum.Name = "lblFollowerNum"
        Me.lblFollowerNum.Size = New System.Drawing.Size(103, 13)
        Me.lblFollowerNum.TabIndex = 2
        Me.lblFollowerNum.Text = "Number of Followers"
        '
        'lblFollowingNum
        '
        Me.lblFollowingNum.AutoSize = True
        Me.lblFollowingNum.Location = New System.Drawing.Point(34, 48)
        Me.lblFollowingNum.Name = "lblFollowingNum"
        Me.lblFollowingNum.Size = New System.Drawing.Size(108, 13)
        Me.lblFollowingNum.TabIndex = 1
        Me.lblFollowingNum.Text = "Number of Followings"
        '
        'lblScore
        '
        Me.lblScore.AutoSize = True
        Me.lblScore.Location = New System.Drawing.Point(34, 97)
        Me.lblScore.Name = "lblScore"
        Me.lblScore.Size = New System.Drawing.Size(35, 13)
        Me.lblScore.TabIndex = 3
        Me.lblScore.Text = "Score"
        '
        'Profile
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(314, 137)
        Me.Controls.Add(Me.lblScore)
        Me.Controls.Add(Me.lblFollowingNum)
        Me.Controls.Add(Me.lblFollowerNum)
        Me.Controls.Add(Me.lblTweetNum)
        Me.Name = "Profile"
        Me.Text = "Profile"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lblTweetNum As System.Windows.Forms.Label
    Friend WithEvents lblFollowerNum As System.Windows.Forms.Label
    Friend WithEvents lblFollowingNum As System.Windows.Forms.Label
    Friend WithEvents lblScore As System.Windows.Forms.Label
End Class
