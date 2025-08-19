using FluentValidation;

namespace HomeApi.Validators;

public static class ValidatorExtensions
{
    public static IRuleBuilderOptions<T, decimal> MustBePositive<T>(this IRuleBuilderInitial<T, decimal> ruleBuilder, string propertyName) =>
        ruleBuilder.GreaterThanOrEqualTo(0).WithMessage(propertyName + " must be greater than or equal to zero.");

    public static void MustBeZeroIf<T>(this IRuleBuilderOptions<T, decimal> ruleBuilder, Func<T, bool> whenPredicate, string propertyName, string dependency) =>
        ruleBuilder.Must(d => d == 0).When(whenPredicate, ApplyConditionTo.CurrentValidator).WithMessage(propertyName + " must be zero if " + dependency);

    public static IRuleBuilderOptions<T, bool> MustBeFalseIf<T>(this IRuleBuilderInitial<T, bool> ruleBuilder, Func<T, bool> whenPredicate, string propertyName, string dependency) =>
        ruleBuilder.Must(b => !b).When(whenPredicate, ApplyConditionTo.CurrentValidator).WithMessage(propertyName + " must be false if " + dependency);

    public static void MustBeFalseIf<T>(this IRuleBuilderOptions<T, bool> ruleBuilder, Func<T, bool> whenPredicate, string propertyName, string dependency) =>
        ruleBuilder.Must(b => !b).When(whenPredicate, ApplyConditionTo.CurrentValidator).WithMessage(propertyName + " must be false if " + dependency);
}
