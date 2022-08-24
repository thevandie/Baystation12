/obj/item/paper/talisman
	icon_state = "paper_talisman"
	info = "<center><img src='talisman.png'></center><br/><br/>"
	language = LANGUAGE_CULT
	abstract_type = /obj/item/paper/talisman
	/// String. The true name of the talisman exposed to cultists on examine.
	var/talisman_name = "default"
	/// String. The description of the talisman effect exposed to cultists on examine.
	var/talisman_desc
	/// Type or list of types. The type(s) that this talisman can be used on.
	var/valid_target_type = /atom


/obj/item/paper/talisman/examine(mob/user, distance)
	. = ..()
	if (iscultist(user))
		to_chat(user, SPAN_OCCULT("This is \a [talisman_name] talisman."))
		if (talisman_desc)
			to_chat(user, SPAN_OCCULT("Effect: [talisman_desc]."))


/obj/item/paper/talisman/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "Attack your target to use this talisman.")
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")


/obj/item/paper/talisman/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!can_invoke(target, user))
		return

	// Null rods block the talisman's effect but still consume it
	var/obj/item/nullrod/nullrod = locate() in target
	if (nullrod)
		user.visible_message(
			SPAN_DANGER("\The [user] invokes \the [src] at \the [target]!"),
			SPAN_DANGER("You invoke \the [talisman_name] talisman at \the [target], but it fails and falls to dust!"),
		)
	else
		user.visible_message(
			SPAN_DANGER("\The [user] invokes \the [src] at \the [target]!"),
			SPAN_DANGER("You invoke \the [talisman_name] talisman at \the [target]!")
		)
		admin_attack_log(user, target, "Used a talisman ([type]).", "Was victim of a talisman ([type]).", "used a talisman ([type]) on")
		invoke(target, user)
	user.say("Talisman {talisman_name}!", all_languages[LANGUAGE_CULT])
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(target)
	qdel(src)


/**
 * Whether or not this talisman can be invoked on the target by the user.
 *
 * **Parameters**:
 * - `target` - The targeted atom.
 * - `user` - The mob attempting to invoke the talisman.
 * - `silent` (boolean) - If set, `user` will not be given any feedback messages on why they cannot invoke the talisman.
 *
 * Returns boolean. Whether or not the talisman can be invoked.
 */
/obj/item/paper/talisman/proc/can_invoke(atom/target, mob/user)
	if (!iscultist(user))
		// No message here even if not silent for non-cultists.
		return FALSE

	if (valid_target_type)
		if (islist(valid_target_type))
			var/isvalid = FALSE
			for (var/type in valid_target_type)
				if (istype(target, type))
					isvalid = TRUE
					break
			if (!isvalid)
				to_chat(user, SPAN_WARNING("\The [talisman_name] talisman cannot be used on \the [target]."))
				return FALSE
		else if (!istype(target, valid_target_type))
			to_chat(user, SPAN_WARNING("\The [talisman_name] talisman cannot be used on \the [target]."))
			return FALSE


	if (!target.Adjacent(user))
		to_chat(user, SPAN_WARNING("You must be next to \the [target] to use \the [talisman_name] talisman on them."))
		return FALSE

	return TRUE


/**
 * Called when a user invokes the talisman against a target. Overrides should contain the code handling the talisman's actual effects. `can_invoke()` is already checked before this is called.
 *
 * **Parameters**:
 * - `target` - The targeted atom.
 * - `user` - The mob attempting to invoke the talisman.
 */
/obj/item/paper/talisman/proc/invoke(atom/target, mob/user)
	return
