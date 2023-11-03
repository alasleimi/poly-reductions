\<^marker>\<open>creator "Kevin Kappelmann"\<close>
theory HOL_To_IMP_Minus_Primitives
  imports
    HOL_To_IMP_Minus_Methods
begin

locale HOL_To_IMP_Minus =
  notes neq0_conv[iff del, symmetric, iff]
begin

definition "is_true_nat n \<equiv> n \<noteq> 0"

lemma is_true_nat_eq[simp]: "is_true_nat = (\<noteq>) 0"
  unfolding is_true_nat_def by simp

definition "is_false_nat n \<equiv> n = 0"

lemma is_false_nat_iff[iff]: "is_false_nat n \<longleftrightarrow> \<not>(is_true_nat n)"
  unfolding is_false_nat_def by simp

definition "true_nat \<equiv> (1 :: nat)"

compile_nat true_nat_def basename true

declare_compiled_const True
  return_register "true_ret"
  argument_registers
  compiled "tailcall_to_IMP_Minus true_IMP_tailcall"

HOL_To_IMP_Minus_func_correct true_nat by (cooker HOL_eqs = true_nat_def)

lemma true_nat_eq_one[simp]: "true_nat = 1"
  unfolding true_nat_def by simp

lemma is_true_nat_true_nat[iff]: "is_true_nat true_nat"
  by simp

definition "false_nat \<equiv> (0 :: nat)"

compile_nat false_nat_def basename false

declare_compiled_const False
  return_register "false_ret"
  argument_registers
  compiled "tailcall_to_IMP_Minus false_IMP_tailcall"

HOL_To_IMP_Minus_func_correct false_nat by (cooker HOL_eqs = false_nat_def)

lemma false_nat_eq_one[simp]: "false_nat = 0"
  unfolding false_nat_def by simp

lemma is_false_nat_false_nat[iff]: "is_false_nat false_nat"
  unfolding false_nat_def by simp

definition "id_nat x \<equiv> (x :: nat)"

compile_nat id_nat_def basename id

HOL_To_IMP_Minus_func_correct id_nat by (cooker HOL_eqs = id_nat_def)

lemma id_nat_eq_id[simp]: "id_nat = id"
  unfolding id_nat_def by (rule ext) simp

definition "nat_of_bool b \<equiv> if b then true_nat else false_nat"

declare_compiled_const nat_of_bool
  return_register "id_ret"
  argument_registers "id_x"
  compiled "tailcall_to_IMP_Minus id_IMP_tailcall"

lemma nat_of_bool_eq_zero_iff[iff]: "nat_of_bool b = 0 \<longleftrightarrow> \<not>b"
  unfolding nat_of_bool_def by simp

lemma nat_of_bool_neq_zero_iff[iff]: "nat_of_bool b \<noteq> 0 \<longleftrightarrow> b"
  unfolding nat_of_bool_def by simp

definition "eq_nat (n :: nat) m \<equiv> nat_of_bool (n = m)"

context includes com_syntax no_com'_syntax
begin

definition [compiled_const_defs]:
  "eq_IMP \<equiv>
    ''eq_x_Sub_y'' ::= (V ''eq_x'' \<ominus> V ''eq_y'');;
    ''eq_y_Sub_x'' ::= (V ''eq_y'' \<ominus> V ''eq_x'');;
    ''eq_neq'' ::= (V ''eq_x_Sub_y'' \<oplus> V ''eq_y_Sub_x'');;
    IF ''eq_neq'' \<noteq>0
    THEN ''eq_ret'' ::= A (N false_nat)
    ELSE ''eq_ret'' ::= A (N true_nat)"

end

declare_compiled_const eq_nat
  return_register "eq_ret"
  argument_registers "eq_x" "eq_y"
  compiled eq_IMP

declare_compiled_const HOL.eq
  return_register "eq_ret"
  argument_registers "eq_x" "eq_y"
  compiled eq_IMP

HOL_To_IMP_Minus_func_correct eq_nat
  unfolding eq_IMP_def eq_nat_def nat_of_bool_def by auto

lemma eq_nat_eq_nat_of_bool_eq[simp]: "eq_nat n m = nat_of_bool (n = m)"
  unfolding eq_nat_def by simp

definition "not_nat (n :: nat) \<equiv> nat_of_bool (n = false_nat)"

compile_nat not_nat_def basename not

declare_compiled_const HOL.Not
  return_register "not_ret"
  argument_registers "not_n"
  compiled "tailcall_to_IMP_Minus not_IMP_tailcall"

HOL_To_IMP_Minus_func_correct not_nat by (cooker HOL_eqs = not_nat_def)

lemma not_nat_eq_nat_of_bool_eq_false[simp]: "not_nat n = nat_of_bool (n = false_nat)"
  unfolding not_nat_def by simp

definition "add_nat (x :: nat) y \<equiv> x + y"
definition "sub_nat (x :: nat) y \<equiv> x - y"

lemma add_nat_eq[simp]: "add_nat = (+)" unfolding add_nat_def by simp
lemma sub_nat_eq[simp]: "sub_nat = (-)" unfolding sub_nat_def by simp

context includes com_syntax no_com'_syntax
begin

definition [compiled_const_defs]: "add_IMP \<equiv> ''add_ret'' ::= (V ''add_x'' \<oplus> V ''add_y'')"
definition [compiled_const_defs]: "sub_IMP \<equiv> ''sub_ret'' ::= (V ''sub_x'' \<ominus> V ''sub_y'')"

end

declare_compiled_const "add_nat"
  return_register "add_ret"
  argument_registers "add_x" "add_y"
  compiled "add_IMP"
declare_compiled_const "Groups.plus"
  return_register "add_ret"
  argument_registers "add_x" "add_y"
  compiled "add_IMP"

declare_compiled_const "sub_nat"
  return_register "sub_ret"
  argument_registers "sub_x" "sub_y"
  compiled "sub_IMP"
declare_compiled_const "Groups.minus"
  return_register "sub_ret"
  argument_registers "sub_x" "sub_y"
  compiled "sub_IMP"

HOL_To_IMP_Minus_func_correct add_nat
  by (auto simp: compiled_const_defs)
HOL_To_IMP_Minus_func_correct sub_nat
  by (auto simp: compiled_const_defs)

definition max_nat :: "nat \<Rightarrow> nat \<Rightarrow> nat" where
  "max_nat x y \<equiv> if x - y \<noteq> 0 then x else y"

compile_nat max_nat_def basename max

declare_compiled_const max
  return_register "max_ret"
  argument_registers "max_x" "max_y"
  compiled "tailcall_to_IMP_Minus max_IMP_tailcall"

HOL_To_IMP_Minus_func_correct max_nat by (cooker HOL_eqs = max_nat_def)

lemma max_nat_eq[simp]: "max_nat x y = max x y"
  unfolding max_nat_def by simp

definition min_nat :: "nat \<Rightarrow> nat \<Rightarrow> nat" where
  "min_nat x y \<equiv> if x - y \<noteq> 0 then y else x"

compile_nat min_nat_def basename min

declare_compiled_const min
  return_register "min_ret"
  argument_registers "min_x" "min_y"
  compiled "tailcall_to_IMP_Minus min_IMP_tailcall"

HOL_To_IMP_Minus_func_correct min_nat by (cooker HOL_eqs = min_nat_def)

lemma min_nat_eq[simp]: "min_nat x y = min x y"
  unfolding min_nat_def by simp

definition "and_nat (x :: nat) y \<equiv> min (min x y) true_nat"

compile_nat and_nat_def basename "and"

declare_compiled_const conj
  return_register "and_ret"
  argument_registers "and_x" "and_y"
  compiled "tailcall_to_IMP_Minus and_IMP_tailcall"

HOL_To_IMP_Minus_func_correct and_nat by (cooker HOL_eqs = and_nat_def)

lemma and_nat_eq[simp]: "and_nat x y = nat_of_bool (is_true_nat x \<and> is_true_nat y)"
  unfolding and_nat_def nat_of_bool_def by auto

definition "or_nat (x :: nat) y \<equiv> min (max x y) true_nat"

compile_nat or_nat_def basename "or"

declare_compiled_const disj
  return_register "or_ret"
  argument_registers "or_x" "or_y"
  compiled "tailcall_to_IMP_Minus or_IMP_tailcall"

HOL_To_IMP_Minus_func_correct or_nat by (cooker HOL_eqs = or_nat_def)

lemma or_nat_eq[simp]: "or_nat x y = nat_of_bool (is_true_nat x \<or> is_true_nat y)"
  unfolding or_nat_def nat_of_bool_def by auto

definition "le_nat (x :: nat) y \<equiv> nat_of_bool (x - y = 0)"

compile_nat le_nat_def basename le

declare_compiled_const "ord_class.less_eq"
  return_register "le_ret"
  argument_registers "le_x" "le_y"
  compiled "tailcall_to_IMP_Minus le_IMP_tailcall"

HOL_To_IMP_Minus_func_correct le_nat by (cooker HOL_eqs = le_nat_def)

lemma le_nat_eq[simp]: "le_nat x y = nat_of_bool (x \<le> y)"
  unfolding le_nat_def by simp

definition "lt_nat (x :: nat) y \<equiv> nat_of_bool (x \<le> y \<and> x \<noteq> y)"

compile_nat lt_nat_def basename lt

declare_compiled_const "ord_class.less"
  return_register "lt_ret"
  argument_registers "lt_x" "lt_y"
  compiled "tailcall_to_IMP_Minus lt_IMP_tailcall"

HOL_To_IMP_Minus_func_correct lt_nat by (cooker HOL_eqs = lt_nat_def)

lemma lt_nat_eq[simp]: "lt_nat x y = nat_of_bool (x < y)"
  unfolding lt_nat_def nat_of_bool_def by auto

end

end
