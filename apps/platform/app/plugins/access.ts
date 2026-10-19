import { AccessAccount, CompleteAccountOnboarding, ReadManagementAccess, StartAccountSocialSignIn } from '#shared/features/access/domain/access';
import { HttpAccountRepository } from '#shared/features/access/data/http_account_repository';
import { AccountViewModel } from '#shared/features/access/presentation/account_view_model';
export default defineNuxtPlugin(() => ({ provide: { accessModel: () => {
  const repository = new HttpAccountRepository();
  return new AccountViewModel(new AccessAccount(repository), new StartAccountSocialSignIn(repository), new CompleteAccountOnboarding(repository), new ReadManagementAccess(repository));
} } }));

