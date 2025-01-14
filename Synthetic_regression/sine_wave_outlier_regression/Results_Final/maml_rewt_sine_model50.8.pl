��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   1552218344176qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1552218344272qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1552218344368qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1552218344656q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1552218345040q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1552218344848q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1552218344176qX   1552218344272qX   1552218344368qX   1552218344656qX   1552218344848qX   1552218345040qe.(       9�����"?��Z��� ��ķ������y��&}�>G2�>�VA?@�r���0$"?=��>�C�	%�=:m�8NJ>�f�>��N�Pyؽ5�9?��1��澸r�<��?�����a���Q?iʼʜ�=|�&?V>;���s������? �<C�(       z!N��.���߼��>y+O>u�OCҿ����Pb�>}b�TL-��Ŀ�S>�'f>K���Cp�����{�=�e<?���>Ǵ��?����>��ؿxuܿ7(���>w�z�7�B�	�����"�>n��Y�⿾��>F��>t���-�K��?�Q�@      Ena�z��Lþ�����?�Ɣ�&鑽p�����$z=c��G�=�E���⿇����b�}���9�ZJ>�k�ym����>h�����=A'���Q�Vc����E�>�@�L�-��s?R��<P
R�7��<�`	��Z�{��c�>�O��cc=KՏ��x>Hb�="~
��b!>p?b�Tǟ��'=>	���2e�'�پ�a?�8�=�� �LȄ�����cp>|�ܿd׽��߽��*>_� �-AȽ+c=>>� �=t�̽WpG�@^�Z̭�H���R3�*C�m��=s�<	@D<��?��޼=F��i���N��=��%�]�E�m���X�}�v�e-u�qh˿i�����.��(���>���T0ɾ&�,�o ��l?t?`�>��t�:N��4;���D��aq�a>��S{f>nec� ? =�����kھ,ݕ?�8,==�5����>څ�<	gӽ*�(��?>yj�~ŷ=��>6����qV���?��D�H�\���=�[
��� =΅E>��~<�h�>�����}����>�� =2�|>8>�@��b>,�߾�ʎ�!I|>�_)>:�޿HRN�.��=�];>���>�������<Z���FA�;,����y�=C�q=xj;���>�G�=�q���h�=�Ȭ�]8<��=�����v��Д�v>��q� d]�2�P?��[>�����=�,};>Ž3���M��RӺ��`�=��;x��<~��=�lm�OQ<�T��Z��T�=�7H�د�s,��*<��B�]qt�Ià�È�= [,�f�1���R��ӽ�}=���=�啾�Y9�f?����I�v>��>�����Qc��}�=4o�>���g�g�;�|�Qr��y��>�����&��L��ȕ=E"���i�(M�<;��>؊Ⱦ��޽J�v�Oq��I�\�"^�}z^�4g�!,�>w�&>Yu�>
GS?�������>�tO��Pw��I	?w��xվDT �h�52����J���p��ř?�$���>���>?@��Z|<�t���W����>4�	�SD����=�.�k���a�5�(�>�Ә�`���ܤ�=�8��3��X�)>i����e8�h�R�'�d�D��3V��&ʽsܢ�������-S�<Z�������!��Y�˼�du�dB<�0ɼ�]��AE.>ϩ��G���[���G�Z�$���S<��1=�����F�*3�=��4�����+��=��ؽX���d�������t�e6K��Տ��A2�1�A������A��\�}=�-=��=���<z>�P-�<0��= U���/Ľ�����rֽ{Nr�M�*��`�4:y^6�e뮽Mz��R������"O���什V��v��Q���Ѽv��l+<I��@h
=Р������>#����^����=Kl���������̩i=U����R��<�����`��=y����`��B������ ;��辰���� ?���T�T�.��Lr�/��� �=)3j�����(����C�=	���;L<0B���=�� 6��u���q����)=+>_<�y��4��=d��_'e>W�:?��#�&�q���M�,�3�&�,�����[�ƽqD�K=�a��B��Ǘ�<3�]�4���(0�*TC��Iǽt�g�!;==Z��Q�<��ݽu�ʽJ�(=�n1���������:�<����p� ���S�<�I=ѥ#��F������y�-���ش@>�셽�c����;�ܼY\�=�+t?��X���
4�>�=Lb���������>�����F��ȝ����|�y�꾂/�?�1 �cp$��~���=ovz�뿆��\����%�O6���.E�u`����Q�s�>:�B���f;�Z��M��<�=HB�?!G2��?���ѽ�A��hlҽ�㟽*S[=�ې�Qˡ=�:a;��_<,�<-���#'m�A�Q����d��=m?���O�Æ�����?�]�;�jo�k�S=�����<jՄ�N��;��	��ҽ��%���>E�=�z�;�ƽ�Z��7L�B��=Q�$y����<ɫ�uZ�=�˽t�Df�<$�@���:=�U�<$��Z���*{��W?h�z>jD�x���3D�=��e�@hſ�"/���C�q@W>n&#�t[�)\>2"�nj�>����t�/��>s���h�-��m�=JA�5�P�bHo=Q`���s��T���]>q�8����=�7�8;��J�>�鱾{�ƽaƗ�o+
�2��4Ƀ>ݔ���gB��o��:�+�žD�޽ȅ�hC�>���>���t�<fοB��O�ټx+�=rl��n��>2�_�U;���>�e�������Ӿ���>��_�W,E�62�>
�G�VOZ�_�[=&����#�������P���{�Gc���jԼ�v��dĬ��I���-���L�.́=�Q��2&>��ݽ�FX�!��=���ʮj�!C/�cw���=��4������1�=�;?��]ý���,J>��@�=^&
� �5��p��h��=i��A��� ��qH�=^�v�ξ�"��P��`�k�%����I�(�� �=!M�?ǿ�4�>h��� l��z��6��>Z3>ý=���+|��ɾ���=�t�f�ݚ?����>��Ó7��n87|<?������"���"?��������K�H�g>�.���8�>�	�@���潓گ��&=5�<]�۽F@�=��7n�S5;qtd��$��l`=�������l��<BĽ_�= ��-IH��=�(ܽ��۞���X >����T��(�}��=�.=j��=� ����=/w�< &=��톀=�;;���W=2n�=�����,���r��f�(�f0�<��?�a�}8=~�����輌�Y���9�c~��e��|�н9Ia=}����(�\!��$7�: N�F�齶���>&M��U�)����H,-=k(/��n��5�H�U���@���н��v����=N܁�.W�F���1��<�D�I�н^M��2��=Q��	�"r���,��S���>{m���X>���J��= .�=�Om��_T�p��9%<�n�x:� �PE8=���c�� ����� �=�ſ<�y�����{����|����<> �Q�8>7$*=b ��Ӥ��;�Am+���W��p�>�y�=/>�y�G>�`�����t�#���T=A���ه����>�VʽyBy������2�>��R>\�(��$��ۈ��0ھƑ�=�N�����xm?���<�����!�:q������K��7�>b�v�kͶ=�d��ib:����໷=�Z�<�����	�_#�l���Tm�P���-輺����JȽ���=6e!�j4	::�(�Dܿ=�c�<^����ρ��1�=�%/�;����3��>���=W���a���o&��i>�g`��9�ӊ��Q~�=u&�=�~��:���>��a��#
� ~Q:g� >��Ӽ5ɼ���V�aU�a?����=Y�)�?�<��3a�����o�<��ۄr����=�ה����r�� �%��������i�������G�=���;�e�=�7=���-�+=��wp�fH��z�<B�뼰(������<�At<�<�=C�j=F���h� P)�0���N�=�Zc�\,	�b뾎��=%�ѽ����+��=r��<<���!"�éܾ|��?u����Ⱦp����ؾw�=�����Tq�]\4��
>f��#?�=��;�=վ�P���wǾx����2���G�p�ٽ�\m���/�j�"��7V�z�E>���og�� 5���[�<	4�>��Ce(�L���J���=���rv=_���aE�b�/��b��l ��z�d��=��޽�/@��=�W�=���"a���&>�qv<�l=����Z��HsȽ�CQ�C�2<�̀�f��6(��Ω��7�<�{w��W>���^w�y��;���>�w?RI�["�>ߘ?���`JL�K��	#���?m���`��@>6�=X�4�=A9=v#�;u�?pq��Ó;\U$��޼>�ݘ�90a=J�(�@ �$D-?;_=�彟�U2�>��"�9��,�%��&c�x��Q�;�9P�g�$�͊��>��=�g>�,|�[�	>����������U>V��=�z��*Ã���>�f��I���꿘�;���0�0>�]��<���L���>�m��Z�!�{���9�?�%$�NA�=ڗ�<1���Vi�.ܝ�^IB?y�P�`��0��>�W�;���c��P/���-*���q,���J�[�>pG>#�)�k_�?��]��o��G�*�V��=A#����=/�*���'��$u���>���Y���?�P���C>u�	]!>�h6?�#<ds��؞?�n�<�x���,u��K#�'m/����<�j�sX<�=cύ�|�K���Ͻڅ����<�V����!����=���V��=��	>�R�o,���_'��<$=�Ƚ��F=^�ۼ�I�=�f��3�=҇H=��iZ>�z�����
r<������>U�^jȼ�t�=�US�A{^�Y�Q��o�F=��_��Ѿ���v��1.�ʎ�=�p����͝�(L�z�;?�]�78<��}�0��<�����鶽��Ǿ4��d�	���=�ٖ��"�
�J?C�8��<�^���T}=��R?�����p=oc%=�(h�q�W<㬾Iy�� ԍ��S?>�i����`=���J����K�>ЁR��V�>�����9>�+��Gꀼ�?�&�>��>ͣ ��5�>y��;�:^�Ģ=0�{<�m�>��R&��ϭ
?���>��>у���C?��㽡�I���#�;>�<r���=?��=���=Ȏ$��_>�^Q=W�����ڽ�m7��{�����>�>��o��p�=^����;X6?dÜ>�<��3��-1>|����[���턾�sY=��>��W�F����]>�j>b�?�H>l���� �>Ȍ8�\К��Ȫ=�뤽dӍ����W��=�������	��=��E�eT���5νO�;=ī�����3�>O��[�=`�d==�1��`�d�a��&4=�]���G<�b��&ݽ��{<b&,�K�>P��=�1���Խ#�F�T7���S�O>HzL=������v�e蟽��ս�����=�g=ۥ$=1a�=/z"�Ϭ�,�ɽ�>E��Q���P_�>Uo�Q�
���p���d�4��=�"��݄���4�>�yl>��H>D`�xO|���\��n��,������ƽ�a���5H>��������[����>�N�<+5(��HJ>�Kþ�<���>������N�U�ƽ�e��3�����'=�ݘ����)���W޾nd3�sj��ȶw>Qg6�Ɖ��R��iN�����[����,��F'���-<�e�l�>�"�hS$�:�>>E"�tܾ�j��������#N����=kQG�7}�����? �F�rLD�<Z��ܾ�ɛ�?�����?���> �˼�&>u�w��?t��|�<��6�=S�<�����]�ϩM>���>��&?/t?U�?���=�;�<.����W���=C�?,iJ>'�Ƚ9 ?>�/�=� ?�Z�>�t�\�>4T>;=���UZ=o��>��=�x5>J�l�A꠾i)��%X9>��ef~=�ھ/5��
�;��;��Q���X�=��kc�=��>���>D�3?*�>�T>���8���r��S�=�/s>��A�H͎�t�>��Ѿ�֘�TjE?���>�w��?᛾{m/>K_���SB�3�>�xF�WFH>K۾����ο	$��*�+��W=�	>Y����ǽdA �>vV�Z�F��h���ýNJK�)�<OR�=�f>��=�/M=�H@��ˡ���8��2���A>i��=D=w����}����I���v�+>@��v�v���G�A���{�=j\����x�:��:��Ľ{�Y=VE���g�(��G�\���ܽ����(>9C�P�<�zҽ&��{�A=kdʽ�.�S�= ��<����1��=؈�<�@m= s!��t�o7�<���j=� �ފ���������� �=J���F\�=�ӽ������l�=�dT���X�z.�=��=ֵ"���<GW��tu��b2S�*�=�>�U�_���ɾ,��=2�������Ԋ�}6�>�v����������~�\T^��)�>�G�����>�M�=�����G=_;x>�k��(� � =�=}=L��
ԕ�5W���x:�Kÿ=۞��漡��ա}?�r��(       w�_<�.b=?K>p��>*z �1ч��eT��[ʾ@E����=��6�j�>r����V^��2>?��,+>偻7�M��3���#��4��W=֪��$��2�>wִ��"羣��<^V��ꦿJy�\�J���E�uF���P��1S�t������F*=       W�(       X����gr��CV?�پ:g=������>}.>�L*�(j{�<B����~?���=$ِ>��y}��y�>g=�Q;dhR;5o���Lm<ó�1���g��:z�+������)?;9�<�4>q�?�E�>��=o>��<�71�>�e�>��~>г뽍��