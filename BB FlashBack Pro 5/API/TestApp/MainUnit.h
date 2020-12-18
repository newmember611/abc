//---------------------------------------------------------------------------

#ifndef MainUnitH
#define MainUnitH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>

#include <FBAPIWrap.h>
//---------------------------------------------------------------------------
extern bool bGenerateUnhadledException;
//---------------------------------------------------------------------------
class TMainForm : public TForm
{
__published:	// IDE-managed Components
        TGroupBox *GroupBox1;
        TButton *btnStartRecording;
        TButton *btnStopRecording;
        TButton *btnSendReport;
        TButton *btnCrash;
        TGroupBox *GroupBox2;
        TButton *btnGenerateUnhandledException;
        TButton *btnGenerateAccessViolation;
        TButton *btnStopErrorCatch;
        TButton *btnStartErrorCatch;
        TButton *btnPauseRecording;
        TButton *btnResumeRecording;
        TButton *btnIsRecording;
        TButton *btnIsPaused;
        TButton *btnIsErrorCatchingOn;
        TEdit *edtFileName;
        TLabel *Label1;
        TButton *btnIsChecker;
        TButton *btnStartChecker;
        TButton *btnStopChecker;
        TButton *btnGetIncMovies;
        TButton *btnRestoreIncMovies;
        TButton *DiscardIncMovies;
        TButton *btnStartRecorder;
        void __fastcall btnStartRecordingClick(TObject *Sender);
        void __fastcall btnStopRecordingClick(TObject *Sender);
        void __fastcall btnSendReportClick(TObject *Sender);
        void __fastcall btnCrashClick(TObject *Sender);
        void __fastcall btnStartErrorCatchClick(TObject *Sender);
        void __fastcall btnStopErrorCatchClick(TObject *Sender);
        void __fastcall btnGenerateAccessViolationClick(TObject *Sender);
        void __fastcall btnGenerateUnhandledExceptionClick(
          TObject *Sender);
        void __fastcall btnPauseRecordingClick(TObject *Sender);
        void __fastcall btnResumeRecordingClick(TObject *Sender);
        void __fastcall btnIsRecordingClick(TObject *Sender);
        void __fastcall btnIsPausedClick(TObject *Sender);
        void __fastcall btnIsErrorCatchingOnClick(TObject *Sender);
        void __fastcall btnIsCheckerClick(TObject *Sender);
        void __fastcall btnStartCheckerClick(TObject *Sender);
        void __fastcall btnStopCheckerClick(TObject *Sender);
        void __fastcall btnGetIncMoviesClick(TObject *Sender);
        void __fastcall btnRestoreIncMoviesClick(TObject *Sender);
        void __fastcall DiscardIncMoviesClick(TObject *Sender);
        void __fastcall btnStartRecorderClick(TObject *Sender);
private:	// User declarations
        TFBAPI* fbapi;
        void __fastcall ShowError(DWORD dwError); 
public:		// User declarations
        __fastcall TMainForm(TComponent* Owner);
        __fastcall ~TMainForm();
};
//---------------------------------------------------------------------------
extern PACKAGE TMainForm *MainForm;
//---------------------------------------------------------------------------
#endif
 