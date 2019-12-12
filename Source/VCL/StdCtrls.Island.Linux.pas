﻿namespace RemObjects.Elements.RTL.Delphi.VCL;

{$IF ISLAND AND LINUX}

{$GLOBALS ON}

interface

uses
  RemObjects.Elements.RTL.Delphi;

type
  TButton = public partial class(TNativeControl)
  protected
    method CreateHandle; partial; override;
    method PlatformSetCaption(aValue: String); partial; override;
    method PlatformSetOnClick(aValue: TNotifyEvent); override;
  end;

  TLabel = public partial class(TNativeControl)
  protected
    method CreateHandle; override;
    method PlatformSetCaption(aValue: String); override;
  end;

  TGroupBox = public partial class(TNativeControl)
  protected
    // GTKFrame can have just a label and ONE child
    // so we add a GTkFixed and place all nedded inside.
    // fHandle = GtkFixed widget used as container
    fInternal: ^gtk.GtkFrame;
    method CreateHandle; override;
    method PlatformSetCaption(aValue: String); override;
  end;

  TEdit = public partial class(TNativeControl)
  protected
    method CreateHandle; override;
    method PlatformSetText(aValue: String); partial;
    method PlatformGetText: String; partial;
    method PlatformGetMaxLength: Integer; partial;
    method PlatformSetMaxLength(aValue: Integer); partial;
    method PlatformGetReadOnly: Boolean; partial;
    method PlatformSetReadOnly(aValue: Boolean); partial;
  end;

  TButtonControl = public partial class(TNativeControl)
  protected
    method PlatformGetChecked: Boolean; virtual; partial;
    method PlatformSetChecked(aValue: Boolean); virtual; partial;
  end;

  TCheckBox = public partial class(TButtonControl)
  protected
    method CreateHandle; override;

    method PlatformSetState(aValue: TCheckBoxState); partial;
    method PlatformSetAllowGrayed(aValue: Boolean); partial;
  end;

  TRadioButton = public class(TButtonControl)
  protected
    method CreateHandle; override;

    method Click; override;
  end;

  TListControlItems = public partial class(TStringList)
  private
    class var fKeyData := "ListItemKeyData".ToAnsiChars(true);
    class var fKeyDataObject := "ListItemKeyDataObject".ToAnsiChars(true);
    method CreateListItem(S: DelphiString; aObject: TObject): ^glib.GList;
  protected
    method PlatformAddItem(S: DelphiString; aObject: TObject);
    method PlatformInsert(aIndex: Integer; S: DelphiString);
    method PlatformClear;
    method PlatformDelete(aIndex: Integer);
  end;

  TListBox = public partial class(TMultiSelectListControl)
  protected
    method CreateHandle; override;
    method PlatformSelectAll;
    method PlatformGetSelected(aIndex: Integer): Boolean;
    method PlatformSetSelected(aIndex: Integer; value: Boolean);
    method PlatformGetSelCount: Integer;
    method PlatformGetMultiSelect: Boolean;
    method PlatformSetMultiSelect(value: Boolean);
    method PlatformClearSelection;
    method PlatformDeleteSelected;
    method PlatformSetItemIndex(value: Integer);
    method PlatformGetItemIndex: Integer;
  end;

  TComboBoxItems = public partial class(TStringList)
    method PlatformAddItem(S: DelphiString; aObject: TObject);
    method PlatformInsert(aIndex: Integer; S: DelphiString);
    method PlatformClear;
    method PlatformDelete(aIndex: Integer);
  end;

  TComboBox = public partial class(TListControl)
  protected
    method CreateHandle; override;
    method PlatformGetText: String;
    method PlatformSetText(aValue: String);
    method PlatformSetOnSelect(aValue: TNotifyEvent);
    method PlatformSetOnChange(aValue: TNotifyEvent);
    method PlatformSelectAll;
    method PlatformClearSelection;
    method PlatformDeleteSelected;
    method PlatformSetItemIndex(value: Integer);
    method PlatformGetItemIndex: Integer;
  end;

procedure PlatformShowMessage(aMessage: String);

implementation

procedure PlatformShowMessage(aMessage: String);
begin
  var lFlags := gtk.GtkDialogFlags.GTK_DIALOG_MODAL;
  var lParent: ^gtk.GtkWindow := if Application.MainForm ≠ nil then ^gtk.GtkWindow(Application.MainForm.Handle) else nil;
  var lMessage := gtk.gtk_message_dialog_new(lParent, lFlags, gtk.GtkMessageType.GTK_MESSAGE_INFO, gtk.GtkButtonsType.GTK_BUTTONS_OK, aMessage);

  //gtk.gtk_widget_show_all(lMessage);
  gtk.gtk_dialog_run(^gtk.GtkDialog(lMessage));
  gtk.gtk_widget_destroy(lMessage);
end;

method TButton.CreateHandle;
begin
  var lCaption := Caption.ToAnsiChars(true);
  fHandle := gtk.gtk_button_new_with_label(@lCaption[0]);
  gtk.gtk_widget_show(fHandle);
end;

method TButton.PlatformSetCaption(aValue: String);
begin
  var lCaption := aValue.ToAnsiChars(true);
  gtk.gtk_button_set_label(^gtk.GtkButton(fHandle), @lCaption[0]);
end;

method TButton.PlatformSetOnClick(aValue: TNotifyEvent);
begin
  gobject.g_signal_connect_data(fHandle, 'clicked', glib.GVoidFunc(^Void(@clicked)), glib.gpointer(GCHandle.Allocate(self).Handle), @gchandlefree, gobject.GConnectFlags(0));
end;

method clicked(app: ^gtk.GtkWidget; userdata: ^Void);
begin
  var lSelf := new GCHandle(NativeInt(userdata)).Target as TButton;
  if lSelf.OnClick ≠ nil then
  lSelf.OnClick(lSelf);
end;

method gchandlefree(data: glib.gpointer; closure: ^gobject.GClosure);
begin
  new GCHandle(NativeInt(data)).Dispose();
end;

method TLabel.CreateHandle;
begin
  var lCaption := Caption.ToAnsiChars(true);
  fHandle := gtk.gtk_label_new(@lCaption[0]);
  gtk.gtk_widget_show(fHandle);
end;

method TLabel.PlatformSetCaption(aValue: String);
begin
  var lCaption := aValue.ToAnsiChars(true);
  gtk.gtk_label_set_text(^gtk.GtkLabel(fHandle), @lCaption[0]);
end;

method TEdit.CreateHandle;
begin
  var lCaption := Text.ToAnsiChars(true);
  fHandle := gtk.gtk_entry_new();
  gtk.gtk_entry_set_text(^gtk.GtkEntry(fHandle), @lCaption[0]);
end;

method TEdit.PlatformSetText(aValue: String);
begin
  var lCaption := aValue.ToAnsiChars(true);
  gtk.gtk_entry_set_text(^gtk.GtkEntry(fHandle), @lCaption[0]);
end;

method TEdit.PlatformGetText: String;
begin
  var lText := gtk.gtk_entry_get_text(^gtk.GtkEntry(fHandle));
  result := String.FromPAnsiChars(lText);
end;

method TEdit.PlatformGetMaxLength: Integer;
begin
  result := gtk.gtk_entry_get_max_length(^gtk.GtkEntry(fHandle));
end;

method TEdit.PlatformSetMaxLength(aValue: Integer);
begin
  gtk.gtk_entry_set_max_length(^gtk.GtkEntry(fHandle), aValue);
end;

method TEdit.PlatformGetReadOnly: Boolean;
begin
  result := Convert.ToBoolean(gtk.gtk_editable_get_editable(^gtk.GtkEntry(fHandle)));
end;

method TEdit.PlatformSetReadOnly(aValue: Boolean);
begin
  gtk.gtk_editable_set_editable(^gtk.GtkEntry(fHandle), Convert.ToInt32(aValue));
end;

method TGroupBox.CreateHandle;
begin
  var lCaption := Caption.ToAnsiChars(true);
  fInternal := ^gtk.GtkFrame(gtk.gtk_frame_new(@lCaption[0]));
  fHandle := gtk.gtk_fixed_new();
  gtk.gtk_container_add(^gtk.GtkContainer(fInternal), fHandle);
end;

method TGroupBox.PlatformSetCaption(aValue: String);
begin
  var lCaption := aValue.ToAnsiChars(true);
  gtk.gtk_frame_set_label(fInternal, @lCaption[0]);
end;

method TButtonControl.PlatformGetChecked: Boolean;
begin
  result := Convert.ToBoolean(gtk.gtk_toggle_button_get_active(^gtk.GtkToggleButton(fHandle)));
end;

method TButtonControl.PlatformSetChecked(aValue: Boolean);
begin
  gtk.gtk_toggle_button_set_active(^gtk.GtkToggleButton(fHandle), Convert.ToInt32(aValue));
end;

method TCheckBox.CreateHandle;
begin
  var lCaption := Caption.ToAnsiChars(true);
  fHandle := gtk.gtk_check_button_new_with_label(@lCaption[0]);
end;

method TCheckBox.PlatformSetState(aValue: TCheckBoxState);
begin
  case aValue of
    TCheckBoxState.cbUnChecked:
      gtk.gtk_toggle_button_set_active(^gtk.GtkToggleButton(fHandle), 0);

    TCheckBoxState.cbChecked:
    gtk.gtk_toggle_button_set_active(^gtk.GtkToggleButton(fHandle), 1);

    TCheckBoxState.cbGrayed:
      gtk.gtk_toggle_button_set_inconsistent(^gtk.GtkToggleButton(fHandle), 1);
  end;
end;

method TCheckBox.PlatformSetAllowGrayed(aValue: Boolean);
begin
  gtk.gtk_toggle_button_set_inconsistent(^gtk.GtkToggleButton(fHandle), Convert.ToInt32(aValue));
end;

method TRadioButton.CreateHandle;
begin
  var lCaption := Caption.ToAnsiChars(true);
  fHandle := gtk.gtk_radio_button_new_with_label(nil, @lCaption[0]);
end;

method TRadioButton.Click;
begin

end;

method TListControlItems.PlatformAddItem(S: DelphiString; aObject: TObject);
begin
  var lList := CreateListItem(S, aObject);
  gtk.gtk_list_append_items(^gtk.GtkList(ListControl.Handle), lList);
end;

method TListControlItems.PlatformInsert(aIndex: Integer; S: DelphiString);
begin
  var lList := CreateListItem(S, nil);
  gtk.gtk_list_insert_items(^gtk.GtkList(ListControl.Handle), lList, aIndex);
end;

method TListControlItems.PlatformClear;
begin
  gtk.gtk_list_clear_items(^gtk.GtkList(ListControl.Handle), 0, Count - 1);
end;

method TListControlItems.PlatformDelete(aIndex: Integer);
begin
  gtk.gtk_list_clear_items(^gtk.GtkList(ListControl.Handle), aIndex, aIndex);
end;

method TListControlItems.CreateListItem(S: DelphiString; aObject: TObject): ^glib.GList;
begin
  result := nil;
  var lText := PlatformString(S).ToAnsiChars(true);
  var lItem := gtk.gtk_list_item_new_with_label(@lText[0]);
  result := glib.g_list_append(^glib.GList(result), lItem);

  gtk.gtk_widget_show(^gtk.GtkWidget(lItem));
  gtk.gtk_object_set_data(^gtk.GtkObject(lItem), @fKeyData[0], @lText[0]);
  gtk.gtk_object_set_data(^gtk.GtkObject(lItem), @fKeyDataObject[0], InternalCalls.Cast(aObject));
end;

method TComboBoxItems.PlatformAddItem(S: DelphiString; aObject: TObject);
begin
  var lText := PlatformString(S).ToAnsiChars(true);
  gtk.gtk_combo_box_text_append_text(^gtk.GtkComboBoxText(ListControl.Handle), @lText[0]);
end;

method TComboBoxItems.PlatformInsert(aIndex: Integer; S: DelphiString);
begin
  var lText := PlatformString(S).ToAnsiChars(true);
  gtk.gtk_combo_box_text_insert_text(^gtk.GtkComboBoxText(ListControl.Handle), aIndex, @lText[0]);
end;

method TComboBoxItems.PlatformClear;
begin
  for i: Integer := 0 to Count - 1 do
    gtk.gtk_combo_box_text_remove(^gtk.GtkComboBoxText(ListControl.Handle), i);
end;

method TComboBoxItems.PlatformDelete(aIndex: Integer);
begin
  gtk.gtk_combo_box_text_remove(^gtk.GtkComboBoxText(ListControl.Handle), aIndex);
end;

method TListBox.CreateHandle;
begin
  fHandle := gtk.gtk_list_new();
end;

method TListBox.PlatformSelectAll;
begin

end;

method TListBox.PlatformGetSelected(aIndex: Integer): Boolean;
begin

end;

method TListBox.PlatformSetSelected(aIndex: Integer; value: Boolean);
begin

end;

method TListBox.PlatformGetSelCount: Integer;
begin

end;

method TListBox.PlatformGetMultiSelect: Boolean;
begin

end;

method TListBox.PlatformSetMultiSelect(value: Boolean);
begin

end;

method TListBox.PlatformClearSelection;
begin

end;

method TListBox.PlatformDeleteSelected;
begin

end;

method TListBox.PlatformSetItemIndex(value: Integer);
begin

end;

method TListBox.PlatformGetItemIndex: Integer;
begin

end;

method TComboBox.CreateHandle;
begin
  if fStyle = TComboBoxStyle.csDropDown then
    fHandle := gtk.gtk_combo_box_text_new_with_entry()
  else
    fHandle := gtk.gtk_combo_box_text_new();
end;

method TComboBox.PlatformGetText: String;
begin

end;

method TComboBox.PlatformSetText(aValue: String);
begin

end;

method TComboBox.PlatformSetOnSelect(aValue: TNotifyEvent);
begin

end;

method TComboBox.PlatformSetOnChange(aValue: TNotifyEvent);
begin

end;

method TComboBox.PlatformSelectAll;
begin

end;

method TComboBox.PlatformClearSelection;
begin

end;

method TComboBox.PlatformDeleteSelected;
begin

end;

method TComboBox.PlatformSetItemIndex(value: Integer);
begin

end;

method TComboBox.PlatformGetItemIndex: Integer;
begin

end;

{$ENDIF}


end.