/*  See LICENSE and COPYING files for copyright and license details. */

#include <gtk/gtk.h>
#include <glib/gi18n.h>
#include "remmina_key_chooser.h"
#include "remmina_public.h"
#include "remmina/remmina_trace_calls.h"

/* Handle key-presses on the GtkEventBox */
static gboolean remmina_key_chooser_dialog_on_key_press(GtkWidget *widget, GdkEventKey *event, RemminaKeyChooserArguments *arguments)
{
	TRACE_CALL("remmina_key_chooser_dialog_on_key_press");
	if (!arguments->use_modifiers || !event->is_modifier)
	{
		arguments->state = event->state;
		arguments->keyval = gdk_keyval_to_lower(event->keyval);
		gtk_dialog_response(GTK_DIALOG(gtk_widget_get_toplevel(widget)),
			event->keyval == GDK_KEY_Escape ? GTK_RESPONSE_CANCEL : GTK_RESPONSE_OK);
	}
	return TRUE;
}

/* Show a key chooser dialog and return the keyval for the selected key */
RemminaKeyChooserArguments* remmina_key_chooser_new(GtkWindow *parent_window, gboolean use_modifiers)
{
	TRACE_CALL("remmina_key_chooser_new");
	GtkBuilder *builder = remmina_public_gtk_builder_new_from_file("remmina_key_chooser.glade");
	GtkDialog *dialog;
	RemminaKeyChooserArguments *arguments;
	arguments = g_new0(RemminaKeyChooserArguments, 1);
	arguments->state = 0;
	arguments->use_modifiers = use_modifiers;

	/* Setup the dialog */
	dialog = GTK_DIALOG(gtk_builder_get_object(builder, "KeyChooserDialog"));
	gtk_window_set_transient_for(GTK_WINDOW(dialog), parent_window);
	/* Connect the GtkEventBox signal */
	g_signal_connect(gtk_builder_get_object(builder, "eventbox_key_chooser"), "key-press-event",
		G_CALLBACK(remmina_key_chooser_dialog_on_key_press), arguments);
	/* Show the dialog and destroy it after the use */
	arguments->response = gtk_dialog_run(dialog);
	gtk_widget_destroy(GTK_WIDGET(dialog));
	/* The delete button set the keyval 0 */
	if (arguments->response == GTK_RESPONSE_REJECT)
		arguments->keyval = 0;
	return arguments;
}

/* Get the uppercase character value of a keyval */
gchar* remmina_key_chooser_get_value(guint keyval, guint state)
{
	TRACE_CALL("remmina_key_chooser_get_value");

	if (!keyval)
		return KEY_CHOOSER_NONE;

	return g_strdup_printf("%s%s%s%s%s%s%s",
		state & GDK_SHIFT_MASK ? KEY_MODIFIER_SHIFT : "",
		state & GDK_CONTROL_MASK ? KEY_MODIFIER_CTRL : "",
		state & GDK_MOD1_MASK ? KEY_MODIFIER_ALT : "",
		state & GDK_SUPER_MASK ? KEY_MODIFIER_SUPER : "",
		state & GDK_HYPER_MASK ? KEY_MODIFIER_HYPER : "",
		state & GDK_META_MASK ? KEY_MODIFIER_META : "",
		gdk_keyval_name(gdk_keyval_to_upper(keyval)));
}

/* Get the keyval of a (lowercase) character value */
guint remmina_key_chooser_get_keyval(const gchar *value)
{
	TRACE_CALL("remmina_key_chooser_get_keyval");
	gchar *patterns[] = {
			KEY_MODIFIER_SHIFT,
			KEY_MODIFIER_CTRL,
			KEY_MODIFIER_ALT,
			KEY_MODIFIER_SUPER,
			KEY_MODIFIER_HYPER,
			KEY_MODIFIER_META,
			NULL
	};
	gint i;
	gchar *tmpvalue;
	gchar *newvalue;
	guint keyval;

	if (g_strcmp0(value, KEY_CHOOSER_NONE) == 0)
		return 0;

	/* Remove any modifier text before to get the keyval */
	newvalue = g_strdup(value);
	for (i = 0; i < g_strv_length(patterns); i++)
	{
		tmpvalue = remmina_public_str_replace(newvalue, patterns[i], "");
		g_free(newvalue);
		newvalue = g_strdup(tmpvalue);
		g_free(tmpvalue);
	}
	keyval = gdk_keyval_to_lower(gdk_keyval_from_name(newvalue));
	g_free(newvalue);
	return keyval;
}
